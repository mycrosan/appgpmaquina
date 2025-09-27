import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/matriz.dart';
import '../../domain/entities/machine_config.dart';
import '../bloc/machine_config_bloc.dart';
import '../bloc/machine_config_event.dart';
import '../bloc/machine_config_state.dart';

class MachineConfigPage extends StatefulWidget {
  final String deviceId;
  final String userId;

  const MachineConfigPage({
    super.key,
    required this.deviceId,
    required this.userId,
  });

  @override
  State<MachineConfigPage> createState() => _MachineConfigPageState();
}

class _MachineConfigPageState extends State<MachineConfigPage> {
  Matriz? selectedMatriz;
  MachineConfig? currentConfig;
  List<Matriz> availableMatrizes = [];

  @override
  void initState() {
    super.initState();
    developer.log('🏗️ Inicializando MachineConfigPage', name: 'MachineConfigUI');
    developer.log('  - Device ID: ${widget.deviceId}', name: 'MachineConfigUI');
    developer.log('  - User ID: ${widget.userId}', name: 'MachineConfigUI');
    _loadData();
  }

  void _loadData() {
    developer.log('🔄 Carregando dados da configuração da máquina', name: 'MachineConfigUI');
    developer.log('📋 Solicitando carregamento de matrizes disponíveis', name: 'MachineConfigUI');
    context.read<MachineConfigBloc>().add(const LoadAvailableMatrizes());
    
    developer.log('🔍 Solicitando carregamento da configuração atual', name: 'MachineConfigUI');
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
        title: const Text('Configuração da Máquina'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (currentConfig != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                developer.log('🗑️ Usuário clicou no botão de remover configuração', name: 'MachineConfigUI');
                _showRemoveConfigDialog();
              },
              tooltip: 'Remover configuração',
            ),
        ],
      ),
      body: BlocListener<MachineConfigBloc, MachineConfigState>(
        listener: (context, state) {
          developer.log('📡 Estado do BLoC alterado: ${state.runtimeType}', name: 'MachineConfigUI');
          
          if (state is MatrizSelectedSuccess) {
            developer.log('✅ Matriz selecionada com sucesso', name: 'MachineConfigUI');
            developer.log('  - Device ID: ${state.config.deviceId}', name: 'MachineConfigUI');
            developer.log('  - User ID: ${state.config.userId}', name: 'MachineConfigUI');
            developer.log('  - Matriz ID: ${state.config.matrizId}', name: 'MachineConfigUI');
            developer.log('  - Data de configuração: ${state.config.configuredAt}', name: 'MachineConfigUI');
            developer.log('  - Configuração completa: ${state.config.toString()}', name: 'MachineConfigUI');
            
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
                    developer.log('👁️ Usuário visualizou detalhes da configuração', name: 'MachineConfigUI');
                  },
                ),
              ),
            );
            setState(() {
              currentConfig = state.config;
            });
          } else if (state is MachineConfigRemovedSuccess) {
            developer.log('✅ Configuração removida com sucesso', name: 'MachineConfigUI');
            developer.log('  - Device ID: ${widget.deviceId}', name: 'MachineConfigUI');
            developer.log('  - User ID: ${widget.userId}', name: 'MachineConfigUI');
            developer.log('  - Configuração anterior removida', name: 'MachineConfigUI');
            
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
                    developer.log('👍 Usuário confirmou remoção da configuração', name: 'MachineConfigUI');
                  },
                ),
              ),
            );
            setState(() {
              currentConfig = null;
              selectedMatriz = null;
            });
          } else if (state is MachineConfigError) {
            AppLogger.error('Erro na configuração da máquina: ${state.message}', name: 'MachineConfigUI');
            AppLogger.ui('Exibindo mensagem de erro para o usuário', name: 'MachineConfigUI');
            
            // Exibe um SnackBar com mais detalhes do erro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Erro na Configuração',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                    developer.log('🔄 Usuário solicitou tentar novamente após erro', name: 'MachineConfigUI');
                    _loadData();
                  },
                ),
              ),
            );
            
            // Também exibe um dialog para erros críticos
            if (state.message.contains('Status: 5') || 
                state.message.contains('Network error') ||
                state.message.contains('Erro ao processar')) {
              AppLogger.error('Erro crítico detectado, exibindo dialog', name: 'MachineConfigUI');
              _showErrorDialog(context, state.message);
            }
          } else if (state is AvailableMatrizesLoaded) {
            developer.log('📋 Matrizes disponíveis carregadas: ${state.matrizes.length} itens', name: 'MachineConfigUI');
            for (var matriz in state.matrizes) {
              developer.log('  - ${matriz.nome} (${matriz.codigo})', name: 'MachineConfigUI');
            }
            
            setState(() {
              availableMatrizes = state.matrizes;
            });
          } else if (state is CurrentMachineConfigLoaded) {
            if (state.config != null) {
              developer.log('🔍 Configuração atual carregada', name: 'MachineConfigUI');
              developer.log('  - Config ID: ${state.config!.id}', name: 'MachineConfigUI');
              developer.log('  - Matriz ID: ${state.config!.matrizId}', name: 'MachineConfigUI');
              developer.log('  - Configurada em: ${state.config!.configuredAt}', name: 'MachineConfigUI');
            } else {
              developer.log('ℹ️ Nenhuma configuração atual encontrada', name: 'MachineConfigUI');
            }
            
            setState(() {
              currentConfig = state.config;
              if (currentConfig != null) {
                selectedMatriz = availableMatrizes.firstWhere(
                  (m) => m.id == currentConfig!.matrizId,
                  orElse: () => availableMatrizes.first,
                );
                developer.log('🎯 Matriz selecionada automaticamente: ${selectedMatriz?.nome}', name: 'MachineConfigUI');
              }
            });
          }
        },
        child: BlocBuilder<MachineConfigBloc, MachineConfigState>(
          builder: (context, state) {
            if (state is MachineConfigLoading) {
              developer.log('⏳ Exibindo indicador de carregamento', name: 'MachineConfigUI');
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentConfigSection(),
                  const SizedBox(height: 24),
                  _buildMatrizSelectionSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
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
                const Icon(Icons.view_module, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Selecionar Matriz',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (availableMatrizes.isEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.warning_outlined, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text('Nenhuma matriz disponível'),
                ],
              ),
            ] else ...[
              DropdownButtonFormField<Matriz>(
                value: selectedMatriz,
                decoration: const InputDecoration(
                  labelText: 'Matriz',
                  border: OutlineInputBorder(),
                ),
                items: availableMatrizes.map((matriz) {
                  return DropdownMenuItem<Matriz>(
                    value: matriz,
                    child: Text('${matriz.nome} (${matriz.codigo})'),
                  );
                }).toList(),
                onChanged: (Matriz? value) {
                  if (value != null) {
                    developer.log('🎯 Usuário selecionou matriz: ${value.nome} (ID: ${value.id})', name: 'MachineConfigUI');
                    developer.log('  - Código: ${value.codigo}', name: 'MachineConfigUI');
                    developer.log('  - Descrição: ${value.descricao}', name: 'MachineConfigUI');
                  } else {
                    developer.log('❌ Usuário desmarcou seleção de matriz', name: 'MachineConfigUI');
                  }
                  
                  setState(() {
                    selectedMatriz = value;
                  });
                },
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: selectedMatriz != null ? () {
              developer.log('💾 Usuário clicou em Salvar Configuração', name: 'MachineConfigUI');
              _saveConfiguration();
            } : null,
            icon: const Icon(Icons.save),
            label: const Text('Salvar Configuração'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            developer.log('🔄 Usuário clicou em Atualizar dados', name: 'MachineConfigUI');
            _loadData();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Atualizar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnSecondary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (selectedMatriz == null) {
      developer.log('⚠️ Tentativa de salvar sem matriz selecionada', name: 'MachineConfigUI');
      return;
    }

    developer.log('💾 Iniciando salvamento da configuração', name: 'MachineConfigUI');
    developer.log('  - Matriz selecionada: ${selectedMatriz!.nome} (ID: ${selectedMatriz!.id})', name: 'MachineConfigUI');
    developer.log('  - Device ID: ${widget.deviceId}', name: 'MachineConfigUI');
    developer.log('  - User ID: ${widget.userId}', name: 'MachineConfigUI');

    context.read<MachineConfigBloc>().add(
      SelectMatrizForMachine(
        matrizId: selectedMatriz!.id.toString(),
        deviceId: widget.deviceId,
        userId: widget.userId,
      ),
    );
  }

  void _showRemoveConfigDialog() {
    developer.log('🗑️ Exibindo diálogo de confirmação para remoção', name: 'MachineConfigUI');
    
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
                developer.log('❌ Usuário cancelou remoção da configuração', name: 'MachineConfigUI');
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                developer.log('✅ Usuário confirmou remoção da configuração', name: 'MachineConfigUI');
                developer.log('  - Device ID: ${widget.deviceId}', name: 'MachineConfigUI');
                developer.log('  - User ID: ${widget.userId}', name: 'MachineConfigUI');
                
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
                Text(
                  'Configuração Atual',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentConfig != null) ...[
              _buildInfoRow('Dispositivo:', widget.deviceId),
              _buildInfoRow('Usuário:', widget.userId),
              _buildInfoRow('Matriz Configurada:', currentConfig!.matrizId.toString()),
              _buildInfoRow(
                'Data de Configuração:',
                currentConfig!.configuredAt.toString().split(' ')[0],
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
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
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
    developer.log('🚨 Exibindo dialog de erro crítico', name: 'MachineConfigUI');
    
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
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
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
              const Text('• Entre em contato com o suporte se o problema persistir'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                developer.log('🔄 Usuário escolheu tentar novamente no dialog', name: 'MachineConfigUI');
                Navigator.of(context).pop();
                _loadData();
              },
              child: const Text('Tentar Novamente'),
            ),
            ElevatedButton(
              onPressed: () {
                developer.log('❌ Usuário fechou dialog de erro', name: 'MachineConfigUI');
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