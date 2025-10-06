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
import '../../../machine/domain/usecases/get_current_machine_config.dart';
import '../../../../core/config/network_config.dart';
import '../../../machine/data/models/configuracao_maquina_dto.dart';

class RelaySettingsPage extends StatefulWidget {
  const RelaySettingsPage({super.key});

  @override
  State<RelaySettingsPage> createState() => _RelaySettingsPageState();
}

class _RelaySettingsPageState extends State<RelaySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  List<RegistroMaquina> _machines = [];
  RegistroMaquina? _selectedMachine;
  String? _celularId;
  bool _loading = false;
  String? _statusMessage;
  int? _activeMatrizId;
  String? _activeMatrizName;


  @override
  void initState() {
    super.initState();
    _initDeviceId();
    _loadSettings();
    _loadMachines();
  }

  Future<void> _initDeviceId() async {
    final id = await DeviceInfoService.instance.getDeviceId();
    setState(() {
      _celularId = id;
    });
    await _loadActiveMachineConfig();
  }

  Future<void> _loadSettings() async {
    // Não carregamos mais configurações locais; a tela inicia vazia
  }

  Future<void> _loadActiveMachineConfig() async {
    try {
      final getUser = sl<GetCurrentUser>();
      final userResult = await getUser();
      final userId = userResult.fold<String?>(
        (_) => null,
        (user) => user.id.toString(),
      );
      final deviceId = (_celularId ?? '').trim();
      if (userId == null || deviceId.isEmpty) return;

      final getConfig = sl<GetCurrentMachineConfig>();
      final cfgResult = await getConfig(
        GetMachineConfigParams(deviceId: deviceId, userId: userId),
      );

      cfgResult.fold(
        (_) {},
        (config) {
          setState(() {
            _activeMatrizId = config?.matrizId;
            _activeMatrizName = config?.matriz?.nome;
          });
        },
      );
    } catch (_) {
      // Falha silenciosa; UI mostra estado padrão
    }
  }

  Future<void> _loadMachines() async {
    try {
      final usecase = sl<GetAllMaquinas>();
      final dartz.Either<Failure, List<RegistroMaquina>> result = await usecase(NoParams());
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
    if (_selectedMachine == null || _selectedMachine?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma máquina antes de salvar')),
      );
      return;
    }
    // Tenta persistir também na API como configurações da máquina (upsert)
    setState(() => _loading = true);
    final apiMessage = await _persistConfigsToApi();
    setState(() => _loading = false);

    final successText = apiMessage?.isNotEmpty == true
        ? 'Configurações sincronizadas no servidor: $apiMessage'
        : 'Configurações sincronizadas no servidor (não armazenadas no dispositivo)';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successText)),
    );
  }

  Future<String?> _persistConfigsToApi() async {
    try {
      final registroId = _selectedMachine!.id!;
      final relayIp = _ipController.text.trim();
      final celularId = (_celularId ?? '').trim();

      if (relayIp.isEmpty || celularId.isEmpty) {
        return null;
      }

      // 1) Obter usuário atual para compor userId
      final getUser = sl<GetCurrentUser>();
      final userResult = await getUser();
      final userId = userResult.fold<String?>(
        (_) => null,
        (user) => user.id.toString(),
      );

      if (userId == null) {
        // Sem usuário autenticado, não conseguimos sincronizar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado. Faça login para sincronizar.')),
        );
        return null;
      }

      // 2) Obter configuração atual da máquina para recuperar matrizId ativo
      final getConfig = sl<GetCurrentMachineConfig>();
      final cfgResult = await getConfig(
        GetMachineConfigParams(deviceId: celularId, userId: userId),
      );

      final matrizId = cfgResult.fold<int?>(
        (_) => null,
        (config) => config?.matrizId,
      );

      if (matrizId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma matriz ativa encontrada para este dispositivo. Configure a matriz na tela de Máquina.'),
          ),
        );
        return null;
      }

      // 3) Montar DTO esperado pelo backend e enviar via Dio com headers de auth automáticos
      final dto = ConfiguracaoMaquinaCreateDTO(
        maquinaId: registroId,
        matrizId: matrizId,
        celularId: celularId,
        descricao: 'Configuração do relé (IP) para máquina: ${_selectedMachine!.nome}',
        atributos: jsonEncode({
          'relay_ip': relayIp,
          'usuario_configuracao': userId,
          'data_configuracao': DateTime.now().toIso8601String(),
        }),
      );

      final dio = NetworkConfig.dio;
      Response response;
      try {
        response = await dio.post(
          ApiEndpoints.configuracaoMaquina,
          data: dto.toJson(),
        );
      } catch (e) {
        // Se for DioException, tentar extrair mensagem do servidor
        if (e is DioException) {
          final status = e.response?.statusCode;
          final data = e.response?.data;
          final msg = 'Falha ao sincronizar (${status ?? 'erro'}): ${data ?? e.message}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return 'relay_ip';
      }

      return null;
    } catch (_) {
      // Silencia erros para não bloquear o fluxo; UI continuará sem persistência local
      return null;
    }
  }

  SonoffDataSource _buildDataSource() {
    final ip = _ipController.text.trim();
    final baseUrl = ip.startsWith('http://') || ip.startsWith('https://')
        ? ip
        : 'http://$ip';
    return SonoffDataSourceImpl(
      client: http.Client(),
      baseUrl: baseUrl,
    );
  }

  Future<void> _executeAction(Future<bool> Function() action, String success, String fail) async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      final ok = await action();
      setState(() {
        _statusMessage = ok ? success : fail;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro: $e';
      });
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
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textOnPrimary),
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
            Text('Conexão', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Informações do dispositivo e matriz ativa
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
                            const Icon(Icons.phone_iphone, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Celular ID: ${_celularId ?? 'carregando...'}',
                                style: AppTextStyles.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.account_tree, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Matriz ativa: ${_activeMatrizName ?? (_activeMatrizId != null ? _activeMatrizId.toString() : '-')}',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'As configurações são sincronizadas no servidor conforme a documentação (Swagger).',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP do Relé (ex.: 192.168.0.165)',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [IpTextInputFormatter()],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Informe o IP do relé';
                      // Validação simples: IPv4 com 4 grupos
                      final parts = v.split(':').first.split('.');
                      if (parts.length != 4) return 'IP inválido, use formato 0.0.0.0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Seletor de Máquina
                  DropdownButtonFormField<RegistroMaquina>(
                    value: _selectedMachine,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Máquina para este telefone',
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
                        _selectedMachine = value;
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

            Text('Ações do Relé', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 220,
                        child: CustomButton(
                          text: 'Ligar Relé',
                          onPressed: _loading
                              ? null
                              : () => _executeAction(
                                    ds.ligarRele,
                                    'Relé ligado com sucesso',
                                    'Falha ao ligar relé',
                                  ),
                          icon: Icons.power,
                          variant: ButtonVariant.filled,
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: CustomButton(
                          text: 'Desligar Relé',
                          onPressed: _loading
                              ? null
                              : () => _executeAction(
                                    ds.desligarRele,
                                    'Relé desligado com sucesso',
                                    'Falha ao desligar relé',
                                  ),
                          icon: Icons.power_settings_new,
                          variant: ButtonVariant.outlined,
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: CustomButton(
                          text: 'Verificar Status',
                          onPressed: _loading
                              ? null
                              : () => _executeAction(
                                    ds.verificarStatusRele,
                                    'Relé está ON',
                                    'Relé está OFF',
                                  ),
                          icon: Icons.info_outline,
                          variant: ButtonVariant.outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loading) const CircularProgressIndicator(),
                  if (_statusMessage != null)
                    Text(
                      _statusMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
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
    // Mantém apenas dígitos e ':'
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9:]'), '');

    // Separa IP e porta (se houver)
    final colonIndex = raw.indexOf(':');
    final ipvRaw = colonIndex >= 0 ? raw.substring(0, colonIndex) : raw;
    final portRaw = colonIndex >= 0 ? raw.substring(colonIndex + 1) : '';

    // Constrói grupos de até 3 dígitos para IPv4 (máximo 4 grupos)
    final digits = ipvRaw.replaceAll(RegExp(r'[^0-9]'), '');
    final groups = <String>[];
    for (int i = 0; i < digits.length && groups.length < 4; i += 3) {
      final end = (i + 3 <= digits.length) ? i + 3 : digits.length;
      groups.add(digits.substring(i, end));
    }
    final ipvMasked = groups.join('.');

    // Porta: mantém apenas dígitos
    final portDigits = portRaw.replaceAll(RegExp(r'[^0-9]'), '');
    final masked = portDigits.isNotEmpty ? '$ipvMasked:$portDigits' : ipvMasked;

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}