import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../injection/data/datasources/sonoff_datasource.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../machine/domain/entities/registro_maquina.dart';
import '../../../machine/domain/usecases/get_all_maquinas.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../machine/domain/entities/configuracao_maquina.dart';
import '../../../machine/domain/usecases/create_configuracao_maquina.dart';
import '../../../machine/domain/usecases/get_configuracao_by_maquina_and_chave.dart';
import '../../../machine/domain/usecases/update_configuracao_maquina.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../../core/config/network_config.dart';
import '../../../machine/data/models/configuracao_maquina_dto.dart';

class _RelayItem {
  final TextEditingController ipController;
  RegistroMaquina? machine;
  _RelayItem({String ip = '', this.machine})
      : ipController = TextEditingController(text: ip);
}
class _RegisteredRelay {
  final int id;
  final String ip;
  final int maquinaId;
  final int? matrizId;
  final String? celularId;
  _RegisteredRelay({
    required this.id,
    required this.ip,
    required this.maquinaId,
    this.matrizId,
    this.celularId,
  });
}

class RelaySettingsPage extends StatefulWidget {
  const RelaySettingsPage({super.key});

  @override
  State<RelaySettingsPage> createState() => _RelaySettingsPageState();
}

class _RelaySettingsPageState extends State<RelaySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  List<RegistroMaquina> _machines = [];
  List<_RelayItem> _relayItems = [];
  List<_RegisteredRelay> _registeredRelays = [];
  bool _loadingRegisteredRelays = false;
  // Status por IP: true (ligado), false (desligado), null (desconhecido)
  final Map<String, bool?> _relayStatus = {};
  String? _celularId;
  bool _loading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _initDeviceId();
    _loadSettings();
    _loadMachines();
    _relayItems.add(_RelayItem());
  }

  Future<void> _initDeviceId() async {
    final id = await DeviceInfoService.instance.getDeviceId();
    setState(() {
      _celularId = id;
    });
    _loadRegisteredRelays();
  }

  @override
  void dispose() {
    for (final item in _relayItems) {
      item.ipController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRegisteredRelays() async {
    final celularId = (_celularId ?? '').trim();
    if (celularId.isEmpty) return;
    setState(() => _loadingRegisteredRelays = true);
    try {
      final dio = NetworkConfig.dio;
      Response response;
      try {
        response = await dio.get(
          ApiEndpoints.rele,
          queryParameters: {
            'celularId': celularId,
          },
        );
      } catch (e) {
        return;
      }

      final data = response.data;
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['content'] is List) {
        items = data['content'];
      }

      final parsed = <_RegisteredRelay>[];
      for (final it in items) {
        if (it is Map) {
          final idVal = it['id'];
          final id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '');
          final ip = (it['ip'] ?? '').toString();
          final maquinaIdStr = (it['maquinaId'] ?? '').toString();
          final maquinaId = int.tryParse(maquinaIdStr);
          final matrizIdStr = it['matrizId']?.toString();
          final matrizId = matrizIdStr != null ? int.tryParse(matrizIdStr) : null;
          final celId = it['celularId']?.toString();
          if (id != null && ip.isNotEmpty && maquinaId != null) {
            parsed.add(
              _RegisteredRelay(
                id: id,
                ip: ip,
                maquinaId: maquinaId,
                matrizId: matrizId,
                celularId: celId,
              ),
            );
          }
        }
      }

      setState(() {
        _registeredRelays = parsed;
      });
      // Após carregar, atualiza o status de cada relé
      await _updateAllRelayStatuses();
    } finally {
      if (mounted) {
        setState(() => _loadingRegisteredRelays = false);
      }
    }
  }

  Future<void> _updateAllRelayStatuses() async {
    for (final r in _registeredRelays) {
      await _checkRelayStatus(r.ip);
    }
  }

  Future<void> _checkRelayStatus(String ip) async {
    try {
      final ds = _buildDataSourceForIp(ip);
      final isOn = await ds.verificarStatusRele();
      if (!mounted) return;
      setState(() {
        _relayStatus[ip] = isOn;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _relayStatus[ip] = null;
      });
    }
  }

  Widget _buildStatusChip(String ip) {
    final st = _relayStatus[ip];
    String label;
    Color textColor;
    Color bgColor;
    if (st == true) {
      label = 'Ligado';
      textColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.10);
    } else if (st == false) {
      label = 'Desligado';
      textColor = AppColors.textSecondary;
      bgColor = AppColors.border.withOpacity(0.20);
    } else {
      label = 'Status';
      textColor = AppColors.textSecondary;
      bgColor = AppColors.surface;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: textColor),
      ),
    );
  }

  Future<void> _updateRelayConfig({
    required int id,
    required String ip,
    required int maquinaId,
  }) async {
    try {
      final celularId = (_celularId ?? '').trim();
      final dio = NetworkConfig.dio;
      final payload = {
        'ip': ip,
        'celularId': celularId,
        'maquinaId': maquinaId,
      };
      final url = '${ApiEndpoints.rele}/$id';
      final response = await dio.put(url, data: payload);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuração atualizada com sucesso')),
        );
        await _loadRegisteredRelays();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao atualizar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
  }

  Future<void> _deleteRelayConfig(_RegisteredRelay r) async {
    try {
      final dio = NetworkConfig.dio;
      final url = '${ApiEndpoints.rele}/${r.id}';
      final response = await dio.delete(url);
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _registeredRelays.removeWhere((e) => e.id == r.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relé removido com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao remover: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover: $e')),
      );
    }
  }

  Future<void> _showEditRelayDialog(_RegisteredRelay r) async {
    final ipController = TextEditingController(text: r.ip);
    RegistroMaquina? selectedMachine;
    try {
      selectedMachine = _machines.firstWhere((m) => m.id == r.maquinaId);
    } catch (_) {}
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Relé'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP do Relé',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [IpTextInputFormatter()],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Informe o IP';
                      final parts = v.split(':').first.split('.');
                      if (parts.length != 4) return 'IP inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RegistroMaquina>(
                    value: selectedMachine,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Máquina',
                      border: OutlineInputBorder(),
                    ),
                    items: _machines.map((m) {
                      return DropdownMenuItem<RegistroMaquina>(
                        value: m,
                        child: Text(m.nome, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => selectedMachine = value,
                    validator: (value) {
                      if (value == null) return 'Selecione uma máquina';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final ip = ipController.text.trim();
                final maquinaId = selectedMachine!.id!;
                await _updateRelayConfig(id: r.id, ip: ip, maquinaId: maquinaId);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSettings() async {
    // Não carregamos mais configurações locais; a tela inicia vazia
  }

  Future<void> _loadMachines() async {
    try {
      final usecase = sl<GetAllMaquinas>();
      final dartz.Either<Failure, List<RegistroMaquina>> result = await usecase(
        NoParams(),
      );
      result.fold(
        (failure) {
          // Apenas loga; UI continuará com lista vazia
        },
        (maquinas) async {
          setState(() {
            _machines = maquinas;
          });
        },
      );
    } catch (_) {
      // Silencia erros para não quebrar a tela de configuração
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    if (_relayItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um relé')),
      );
      return;
    }
    setState(() => _loading = true);
    final apiMessage = await _persistConfigsToApi();
    setState(() => _loading = false);

    final successText = apiMessage?.isNotEmpty == true
        ? 'Configurações sincronizadas: $apiMessage'
        : 'Configurações sincronizadas (não armazenadas no dispositivo)';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successText)));

    _loadRegisteredRelays();
  }

  Future<String?> _persistConfigsToApi() async {
    try {
      final celularId = (_celularId ?? '').trim();
      if (celularId.isEmpty) return null;

      // 1) Obter usuário atual para compor userId
      final getUser = sl<GetCurrentUser>();
      final userResult = await getUser();
      final userId = userResult.fold<String?>(
        (_) => null,
        (user) => user.id.toString(),
      );
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Usuário não autenticado. Faça login para sincronizar.',
            ),
          ),
        );
        return null;
      }

      // 2) Itera itens e envia um POST por máquina
      int successCount = 0;
      int total = 0;

      final dio = NetworkConfig.dio;
      for (final item in _relayItems) {
        final relayIp = item.ipController.text.trim();
        final registroId = item.machine?.id;
        if (relayIp.isEmpty || registroId == null) continue;
        total++;

        final payload = {
          'ip': relayIp,
          'celularId': celularId,
          'maquinaId': registroId,
        };

        try {
          final response = await dio.post(ApiEndpoints.rele, data: payload);
          if (response.statusCode == 200 || response.statusCode == 201) {
            successCount++;
          }
        } catch (e) {
          if (e is DioException) {
            final status = e.response?.statusCode;
            final data = e.response?.data;
            final msg =
                'Falha ao sincronizar (${status ?? 'erro'}): ${data ?? e.message}';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          }
        }
      }

      if (total == 0) return null;
      return '$successCount de $total';
    } catch (_) {
      return null;
    }
  }

  SonoffDataSource _buildDataSource() {
    final ip = _relayItems.isNotEmpty
        ? _relayItems.first.ipController.text.trim()
        : '';
    final baseUrl = ip.startsWith('http://') || ip.startsWith('https://')
        ? ip
        : 'http://$ip';
    return SonoffDataSourceImpl(client: http.Client(), baseUrl: baseUrl);
  }

  // Cria uma fonte de dados do relé baseada em um IP específico
  SonoffDataSource _buildDataSourceForIp(String ip) {
    final baseUrl = ip.startsWith('http://') || ip.startsWith('https://')
        ? ip
        : 'http://$ip';
    return SonoffDataSourceImpl(client: http.Client(), baseUrl: baseUrl);
  }

  Future<void> _executeAction(
    Future<bool> Function() action,
    String success,
    String fail,
  ) async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      final ok = await action();
      setState(() {
        _statusMessage = ok ? success : fail;
      });
      final msg = ok ? success : fail;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = _buildDataSource();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Configuração do Relé',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conexão',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Informações do dispositivo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_iphone,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Celular',
                                    style: AppTextStyles.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _celularId ?? 'carregando...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Lista dinâmica de relés (IP + máquina)
                  ...List.generate(_relayItems.length, (index) {
                    final item = _relayItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: item.ipController,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'IP do Relé (ex.: 192.168.0.165)',
                                      border: OutlineInputBorder(),
                                    ),
                                    inputFormatters: [IpTextInputFormatter()],
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) {
                                        return 'Informe o IP do relé';
                                      }
                                      final parts =
                                          v.split(':').first.split('.');
                                      if (parts.length != 4) {
                                        return 'IP inválido, use formato 0.0.0.0';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  tooltip: 'Remover relé',
                                  onPressed: _relayItems.length > 1
                                      ? () => setState(() {
                                            _relayItems.removeAt(index);
                                          })
                                      : null,
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<RegistroMaquina>(
                              value: item.machine,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Máquina para este relé',
                                border: OutlineInputBorder(),
                              ),
                              items: _machines.map((m) {
                                return DropdownMenuItem<RegistroMaquina>(
                                  value: m,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      m.nome,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  item.machine = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) return 'Selecione uma máquina';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _relayItems.add(_RelayItem());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar relé'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 240,
                  child: CustomButton(
                    text: 'Salvar Configuração',
                    onPressed: _loading ? null : _saveSettings,
                    variant: ButtonVariant.filled,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Relés cadastrados',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _loadingRegisteredRelays
                          ? null
                          : _loadRegisteredRelays,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Atualizar'),
                    ),
                  ),
                  if (_loadingRegisteredRelays)
                    const Center(child: CircularProgressIndicator())
                  else if (_registeredRelays.isEmpty)
                    Text(
                      'Nenhum relé cadastrado para este dispositivo.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    Column(
                      children: _registeredRelays.map((r) {
                        String machineName = 'Máquina #${r.maquinaId}';
                        try {
                          final m = _machines.firstWhere(
                            (mm) => mm.id == r.maquinaId,
                          );
                          machineName = m.nome;
                        } catch (_) {}
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Linha 1: Nome da máquina (acima)
                                Row(
                                  children: [
                                    const Icon(Icons.memory, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        machineName,
                                        style: AppTextStyles.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _buildStatusChip(r.ip),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Editar configuração',
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: () => _showEditRelayDialog(r),
                                      icon: const Icon(Icons.edit, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip: 'Remover relé',
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) {
                                            return AlertDialog(
                                              title: const Text('Remover relé'),
                                              content: const Text('Tem certeza que deseja remover este relé?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                  child: const Text('Remover'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirmed == true) {
                                          await _deleteRelayConfig(r);
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Linha 2: IP (à esquerda) + botões pequenos (à direita)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.ip,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Ligar',
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: _loading
                                          ? null
                                          : () {
                                              final dsItem = _buildDataSourceForIp(r.ip);
                                              _executeAction(
                                                dsItem.ligarRele,
                                                'Relé ligado com sucesso',
                                                'Falha ao ligar relé',
                                              );
                                              _checkRelayStatus(r.ip);
                                            },
                                      icon: const Icon(Icons.power, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Desligar',
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: _loading
                                          ? null
                                          : () {
                                              final dsItem = _buildDataSourceForIp(r.ip);
                                              _executeAction(
                                                dsItem.desligarRele,
                                                'Relé desligado com sucesso',
                                                'Falha ao desligar relé',
                                              );
                                              _checkRelayStatus(r.ip);
                                            },
                                      icon: const Icon(Icons.power_settings_new, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ações por relé agora estão em cada card da lista de cadastrados
          ],
        ),
      ),
    );
  }
}

/// Formatter para aplicar máscara de IPv4 opcionalmente com porta
class IpTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Mantém apenas dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limita ao máximo 10 dígitos (xxx.xxx.x.xxx => 3+3+1+3)
    final digits = digitsOnly.length > 10
        ? digitsOnly.substring(0, 10)
        : digitsOnly;

    // Monta grupos conforme a máscara: 3,3,1,3
    String g1 = '';
    String g2 = '';
    String g3 = '';
    String g4 = '';

    if (digits.isNotEmpty) {
      g1 = digits.substring(0, digits.length >= 3 ? 3 : digits.length);
    }
    if (digits.length > g1.length) {
      final start = g1.length;
      final end =
          start + (digits.length - start >= 3 ? 3 : digits.length - start);
      g2 = digits.substring(start, end);
    }
    if (digits.length > g1.length + g2.length) {
      final start = g1.length + g2.length;
      final end =
          start + (digits.length - start >= 1 ? 1 : digits.length - start);
      g3 = digits.substring(start, end);
    }
    if (digits.length > g1.length + g2.length + g3.length) {
      final start = g1.length + g2.length + g3.length;
      final end =
          start + (digits.length - start >= 3 ? 3 : digits.length - start);
      g4 = digits.substring(start, end);
    }

    // Junta com pontos somente os grupos existentes
    final parts = <String>[];
    if (g1.isNotEmpty) parts.add(g1);
    if (g2.isNotEmpty) parts.add(g2);
    if (g3.isNotEmpty) parts.add(g3);
    if (g4.isNotEmpty) parts.add(g4);
    final masked = parts.join('.');

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}
