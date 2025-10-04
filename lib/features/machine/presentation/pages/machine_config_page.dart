import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/matriz.dart';
import '../../domain/entities/machine_config.dart';
import '../../domain/entities/registro_maquina.dart';
import '../../domain/repositories/registro_maquina_repository.dart';
import '../bloc/machine_config_bloc.dart';
import '../bloc/machine_config_event.dart';
import '../bloc/machine_config_state.dart';

class MachineConfigPage extends StatefulWidget {
  final String deviceId;
  final String userId;
  final int? registroMaquinaId;

  const MachineConfigPage({
    super.key,
    required this.deviceId,
    required this.userId,
    this.registroMaquinaId,
  });

  @override
  State<MachineConfigPage> createState() => _MachineConfigPageState();
}

class _MachineConfigPageState extends State<MachineConfigPage> {
  Matriz? selectedMatriz;
  MachineConfig? currentConfig;
  List<Matriz> availableMatrizes = [];
  List<RegistroMaquina> availableMachines = [];
  RegistroMaquina? selectedMachine;
  // ID do celular será capturado automaticamente
  final String _celularId = "CEL001"; // Valor padrão para envio
  // Query de busca para seleção de matriz
  String _matrizSearchQuery = '';

  @override
  void initState() {
    super.initState();
    developer.log(
      '🏗️ Inicializando MachineConfigPage',
      name: 'MachineConfigUI',
    );
    developer.log('  - Device ID: ${widget.deviceId}', name: 'MachineConfigUI');
    developer.log('  - User ID: ${widget.userId}', name: 'MachineConfigUI');
    _loadData();
    _loadMachines();
  }

  void _loadMachines() async {
    developer.log(
      '🔄 Carregando máquinas disponíveis da API',
      name: 'MachineConfigUI',
    );

    // Importando o repositório de registro de máquinas
    final registroMaquinaRepository = sl<RegistroMaquinaRepository>();

    // Buscando máquinas da API
    final result = await registroMaquinaRepository.getAllMaquinas();

    result.fold(
      (failure) {
        developer.log(
          '❌ Erro ao carregar máquinas: $failure',
          name: 'MachineConfigUI',
        );
        // Em caso de falha, exibe mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar máquinas. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (machines) {
        setState(() {
          availableMachines = machines;

          // Se registroMaquinaId foi fornecido, tenta encontrar e selecionar a máquina correspondente
          if (widget.registroMaquinaId != null) {
            try {
              selectedMachine = machines.firstWhere(
                (machine) => machine.id == widget.registroMaquinaId,
              );
              developer.log(
                '🎯 Máquina selecionada automaticamente: ${selectedMachine!.nome} (ID: ${selectedMachine!.id})',
                name: 'MachineConfigUI',
              );
            } catch (e) {
              developer.log(
                '⚠️ Máquina com ID ${widget.registroMaquinaId} não encontrada nas máquinas disponíveis',
                name: 'MachineConfigUI',
              );
            }
          }
        });
        developer.log(
          '✅ ${machines.length} máquinas carregadas com sucesso',
          name: 'MachineConfigUI',
        );
      },
    );
    // Exemplo de implementação futura:
    // context.read<MachineConfigBloc>().add(const LoadAvailableMachines());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadData() {
    developer.log(
      '🔄 Carregando dados da configuração da máquina',
      name: 'MachineConfigUI',
    );
    developer.log(
      '📋 Solicitando carregamento de matrizes disponíveis',
      name: 'MachineConfigUI',
    );
    context.read<MachineConfigBloc>().add(const LoadAvailableMatrizes());

    developer.log(
      '🔍 Solicitando carregamento da configuração atual',
      name: 'MachineConfigUI',
    );
    context.read<MachineConfigBloc>().add(
      LoadCurrentMachineConfig(
        deviceId: widget.deviceId,
        userId: widget.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config. da Máquina'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (currentConfig != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                developer.log(
                  '🗑️ Usuário clicou no botão de remover configuração',
                  name: 'MachineConfigUI',
                );
                _showRemoveConfigDialog();
              },
              tooltip: 'Remover configuração',
            ),
        ],
      ),
      body: BlocListener<MachineConfigBloc, MachineConfigState>(
        listener: (context, state) {
          developer.log(
            '📡 Estado do BLoC alterado: ${state.runtimeType}',
            name: 'MachineConfigUI',
          );

          if (state is MatrizSelectedSuccess) {
            developer.log(
              '✅ Matriz selecionada com sucesso',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - Device ID: ${state.config.deviceId}',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - User ID: ${state.config.userId}',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - Matriz ID: ${state.config.matrizId}',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - Data de configuração: ${state.config.configuredAt}',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - Configuração completa: ${state.config.toString()}',
              name: 'MachineConfigUI',
            );

            // Exibir SnackBar de sucesso com mais detalhes
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Matriz configurada com sucesso!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Matriz ID: ${state.config.matrizId}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Ver Detalhes',
                  textColor: Colors.white,
                  onPressed: () {
                    developer.log(
                      '👁️ Usuário visualizou detalhes da configuração',
                      name: 'MachineConfigUI',
                    );
                  },
                ),
              ),
            );
            setState(() {
              currentConfig = state.config;
            });
          } else if (state is MachineConfigRemovedSuccess) {
            developer.log(
              '✅ Configuração removida com sucesso',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - Device ID: ${widget.deviceId}',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - User ID: ${widget.userId}',
              name: 'MachineConfigUI',
            );
            developer.log(
              '  - Configuração anterior removida',
              name: 'MachineConfigUI',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Configuração removida com sucesso!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    developer.log(
                      '👍 Usuário confirmou remoção da configuração',
                      name: 'MachineConfigUI',
                    );
                  },
                ),
              ),
            );
            setState(() {
              currentConfig = null;
              selectedMatriz = null;
            });
          } else if (state is MachineConfigError) {
            AppLogger.error(
              'Erro na configuração da máquina: ${state.message}',
              name: 'MachineConfigUI',
            );
            AppLogger.ui(
              'Exibindo mensagem de erro para o usuário',
              name: 'MachineConfigUI',
            );

            // Exibe um SnackBar com mais detalhes do erro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Erro na Configuração',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verifique sua conexão e tente novamente.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 6),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: Colors.white,
                  onPressed: () {
                    developer.log(
                      '🔄 Usuário solicitou tentar novamente após erro',
                      name: 'MachineConfigUI',
                    );
                    _loadData();
                  },
                ),
              ),
            );

            // Também exibe um dialog para erros críticos
            if (state.message.contains('Status: 5') ||
                state.message.contains('Network error') ||
                state.message.contains('Erro ao processar')) {
              AppLogger.error(
                'Erro crítico detectado, exibindo dialog',
                name: 'MachineConfigUI',
              );
              _showErrorDialog(context, state.message);
            }
          } else if (state is AvailableMatrizesLoaded) {
            developer.log(
              '📋 Matrizes disponíveis carregadas: ${state.matrizes.length} itens',
              name: 'MachineConfigUI',
            );
            for (var matriz in state.matrizes) {
              developer.log(
                '  - ${matriz.nome} (${matriz.codigo})',
                name: 'MachineConfigUI',
              );
            }

            setState(() {
              availableMatrizes = state.matrizes;
            });
          } else if (state is CurrentMachineConfigLoaded) {
            if (state.config != null) {
              developer.log(
                '🔍 Configuração atual carregada',
                name: 'MachineConfigUI',
              );
              developer.log(
                '  - Config ID: ${state.config!.id}',
                name: 'MachineConfigUI',
              );
              developer.log(
                '  - Matriz ID: ${state.config!.matrizId}',
                name: 'MachineConfigUI',
              );
              developer.log(
                '  - Configurada em: ${state.config!.configuredAt}',
                name: 'MachineConfigUI',
              );
            } else {
              developer.log(
                'ℹ️ Nenhuma configuração atual encontrada',
                name: 'MachineConfigUI',
              );
            }

            setState(() {
              currentConfig = state.config;
              if (currentConfig != null) {
                try {
                  selectedMatriz = availableMatrizes.firstWhere(
                    (m) => m.id == currentConfig!.matrizId,
                  );
                } catch (e) {
                  // Se não encontrar a matriz específica, usa a primeira disponível
                  selectedMatriz = availableMatrizes.isNotEmpty
                      ? availableMatrizes.first
                      : null;
                }
                developer.log(
                  '🎯 Matriz selecionada automaticamente: ${selectedMatriz?.nome}',
                  name: 'MachineConfigUI',
                );
              }
            });
          }
        },
        child: BlocBuilder<MachineConfigBloc, MachineConfigState>(
          builder: (context, state) {
            if (state is MachineConfigLoading) {
              developer.log(
                '⏳ Exibindo indicador de carregamento',
                name: 'MachineConfigUI',
              );
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentConfigSection(),
                  const SizedBox(height: 24),
                  // Só mostra o card de seleção quando não há configuração atual
                  if (currentConfig == null) ...[
                    _buildMatrizSelectionSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMatrizSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Config. da Máquina',
                    style: AppTextStyles.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seleção de Máquina
            const Text(
              'Selecione a Máquina:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (availableMachines.isEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.warning_outlined, color: AppColors.warning),
                  SizedBox(width: 8),
                  Flexible(child: Text('Nenhuma máquina disponível')),
                ],
              ),
            ] else ...[
              DropdownButtonFormField<RegistroMaquina>(
                value: selectedMachine,
                decoration: const InputDecoration(
                  labelText: 'Máquina',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: availableMachines.map((maquina) {
                  return DropdownMenuItem<RegistroMaquina>(
                    value: maquina,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        maquina.nome,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (RegistroMaquina? value) {
                  if (value != null) {
                    developer.log(
                      '🎯 Usuário selecionou máquina: ${value.nome} (ID: ${value.id})',
                      name: 'MachineConfigUI',
                    );
                  } else {
                    developer.log(
                      '❌ Usuário desmarcou seleção de máquina',
                      name: 'MachineConfigUI',
                    );
                  }

                  setState(() {
                    selectedMachine = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 24),

            // Seleção de Matriz
            const Text(
              'Selecione a Matriz:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (availableMatrizes.isEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.warning_outlined, color: AppColors.warning),
                  SizedBox(width: 8),
                  Flexible(child: Text('Nenhuma matriz disponível')),
                ],
              ),
            ] else ...[
              InkWell(
                onTap: _openMatrizSearch,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Matriz',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      selectedMatriz == null
                          ? 'Toque para pesquisar'
                          : '${selectedMatriz!.nome}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: selectedMatriz == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              if (selectedMatriz != null) ...[
                const SizedBox(height: 16),
                _buildMatrizDetails(selectedMatriz!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _openMatrizSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = _matrizSearchQuery;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<Matriz> filtered = availableMatrizes.where((m) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return m.nome.toLowerCase().contains(q) ||
                  m.codigo.toLowerCase().contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.view_module, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Selecionar Matriz',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar matriz',
                        hintText: 'Digite nome ou código',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          query = value;
                          _matrizSearchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Nenhuma matriz encontrada',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final m = filtered[index];
                            final selected = selectedMatriz?.id == m.id;
                            return ListTile(
                              title: Text(m.nome),
                              trailing: selected
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  selectedMatriz = m;
                                  _matrizSearchQuery = '';
                                });
                                developer.log(
                                  '📋 Matriz selecionada: ${m.nome} (ID: ${m.id})',
                                  name: 'MachineConfigUI',
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Salvar Configuração'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: (selectedMatriz == null || selectedMachine == null)
                ? null
                : () {
                    developer.log(
                      '💾 Usuário clicou em salvar configuração',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - Máquina selecionada: ${selectedMachine!.nome}',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - ID da Máquina: ${selectedMachine!.id}',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - Matriz selecionada: ${selectedMatriz!.nome}',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - ID da Matriz: ${selectedMatriz!.id}',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - Device ID: ${widget.deviceId}',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - User ID: ${widget.userId}',
                      name: 'MachineConfigUI',
                    );
                    developer.log(
                      '  - ID do Celular (capturado automaticamente): ${_celularId}',
                      name: 'MachineConfigUI',
                    );

                    _saveConfiguration();
                  },
          ),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (selectedMatriz == null) {
      developer.log(
        '⚠️ Tentativa de salvar sem matriz selecionada',
        name: 'MachineConfigUI',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma matriz para continuar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (selectedMachine == null) {
      developer.log(
        '⚠️ Tentativa de salvar sem máquina selecionada',
        name: 'MachineConfigUI',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma máquina para continuar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    developer.log(
      '💾 Iniciando salvamento da configuração',
      name: 'MachineConfigUI',
    );
    developer.log(
      '  - Matriz selecionada: ${selectedMatriz!.nome} (ID: ${selectedMatriz!.id})',
      name: 'MachineConfigUI',
    );
    developer.log(
      '  - Máquina selecionada: ${selectedMachine!.nome} (ID: ${selectedMachine!.id})',
      name: 'MachineConfigUI',
    );
    developer.log('  - Device ID: ${widget.deviceId}', name: 'MachineConfigUI');
    developer.log('  - User ID: ${widget.userId}', name: 'MachineConfigUI');
    developer.log(
      '  - ID do Celular (capturado automaticamente): ${_celularId}',
      name: 'MachineConfigUI',
    );

    context.read<MachineConfigBloc>().add(
      SelectMatrizForMachine(
        matrizId: selectedMatriz!.id,
        deviceId: widget.deviceId,
        userId: widget.userId,
        registroMaquinaId: selectedMachine!.id,
      ),
    );
  }

  void _showRemoveConfigDialog() {
    developer.log(
      '🗑️ Exibindo diálogo de confirmação para remoção',
      name: 'MachineConfigUI',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Configuração'),
          content: const Text(
            'Tem certeza que deseja remover a configuração atual da máquina?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                developer.log(
                  '❌ Usuário cancelou remoção da configuração',
                  name: 'MachineConfigUI',
                );
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                developer.log(
                  '✅ Usuário confirmou remoção da configuração',
                  name: 'MachineConfigUI',
                );
                developer.log(
                  '  - Device ID: ${widget.deviceId}',
                  name: 'MachineConfigUI',
                );
                developer.log(
                  '  - User ID: ${widget.userId}',
                  name: 'MachineConfigUI',
                );

                Navigator.of(context).pop();
                context.read<MachineConfigBloc>().add(
                  RemoveMachineConfig(
                    deviceId: widget.deviceId,
                    userId: widget.userId,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Config. Atual', style: AppTextStyles.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            if (currentConfig != null) ...[
              _buildInfoRow('Dispositivo:', widget.deviceId),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  String userName = widget.userId;
                  if (authState is AuthAuthenticated) {
                    userName = authState.user.name ?? authState.user.username;
                  }
                  return _buildInfoRow('Usuário:', userName);
                },
              ),
              // Nome da Máquina (prioriza selectedMachine, mas também tenta buscar por registroMaquinaId)
              if (selectedMachine != null) ...[
                _buildInfoRow('Máquina:', selectedMachine!.nome),
              ] else if (widget.registroMaquinaId != null &&
                  availableMachines.isNotEmpty) ...[
                Builder(
                  builder: (context) {
                    try {
                      final machine = availableMachines.firstWhere(
                        (m) => m.id == widget.registroMaquinaId,
                      );
                      return _buildInfoRow('Nome da Máquina:', machine.nome);
                    } catch (e) {
                      return _buildInfoRow(
                        'ID da Máquina:',
                        widget.registroMaquinaId.toString(),
                      );
                    }
                  },
                ),
              ],
              _buildInfoRow(
                'Matriz:',
                selectedMatriz?.nome ??
                    _getMatrizNameById(currentConfig!.matrizId),
              ),
              _buildInfoRow(
                'Data:',
                _formatBrazilianDate(currentConfig!.configuredAt),
              ),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text('Nenhuma configuração encontrada'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _getMatrizNameById(dynamic matrizId) {
    if (matrizId == null) return '-';
    try {
      final m = availableMatrizes.firstWhere((m) => m.id == matrizId);
      return m.nome;
    } catch (_) {
      return matrizId.toString();
    }
  }

  String _formatBrazilianDate(dynamic configuredAt) {
    DateTime d;
    if (configuredAt is DateTime) {
      d = configuredAt;
    } else if (configuredAt is String) {
      d = DateTime.tryParse(configuredAt) ?? DateTime.now();
    } else {
      return configuredAt.toString();
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  Widget _buildMatrizDetails(Matriz matriz) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes da Matriz',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Nome:', matriz.nome),
          _buildInfoRow('Código:', matriz.codigo),
          _buildInfoRow('Descrição:', matriz.descricao),
          _buildInfoRow('Status:', matriz.isActive ? 'Ativo' : 'Inativo'),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    developer.log(
      '🚨 Exibindo dialog de erro crítico',
      name: 'MachineConfigUI',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          title: const Text(
            'Erro de Configuração',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ocorreu um erro ao tentar configurar a máquina:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Possíveis soluções:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text('• Verifique sua conexão com a internet'),
              const Text('• Certifique-se de que o servidor está funcionando'),
              const Text('• Tente novamente em alguns minutos'),
              const Text(
                '• Entre em contato com o suporte se o problema persistir',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                developer.log(
                  '🔄 Usuário escolheu tentar novamente no dialog',
                  name: 'MachineConfigUI',
                );
                Navigator.of(context).pop();
                _loadData();
              },
              child: const Text('Tentar Novamente'),
            ),
            ElevatedButton(
              onPressed: () {
                developer.log(
                  '❌ Usuário fechou dialog de erro',
                  name: 'MachineConfigUI',
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
