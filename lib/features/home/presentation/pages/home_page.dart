import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../injection/presentation/bloc/injection_bloc.dart';
import '../../../machine/presentation/bloc/registro_maquina_bloc.dart';
import '../../../machine/presentation/bloc/registro_maquina_event.dart';
import '../../../machine/presentation/bloc/registro_maquina_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/services/device_info_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/process_status_card.dart';
import '../widgets/quick_actions_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Carregar processo ativo ao inicializar
    context.read<InjectionBloc>().add(
      const InjectionLoadCurrentActiveProcess(),
    );
  }

  void _handleLogout() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  void _navigateToMachines() async {
    // Obter dados reais do contexto
    String? userId;
    String deviceId = 'unknown_device';
    int? registroMaquinaId;

    // 1. Obter userId do AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id.toString();
    }

    // 2. Obter deviceId do DeviceInfoService
    try {
      deviceId = await DeviceInfoService.instance.getDeviceId();
    } catch (e) {
      // Fallback para deviceId padrão em caso de erro
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    // 3. Tentar obter registroMaquinaId da máquina atual do dispositivo
    final registroMaquinaState = context.read<RegistroMaquinaBloc>().state;
    if (registroMaquinaState is CurrentDeviceMachineLoaded && 
        registroMaquinaState.currentMachine != null) {
      registroMaquinaId = registroMaquinaState.currentMachine!.id;
    } else {
      // Se não há máquina atual, buscar a primeira máquina disponível
      context.read<RegistroMaquinaBloc>().add(const GetCurrentDeviceMachineEvent());
      
      // Aguardar um momento para o estado ser atualizado
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedState = context.read<RegistroMaquinaBloc>().state;
      if (updatedState is CurrentDeviceMachineLoaded && 
          updatedState.currentMachine != null) {
        registroMaquinaId = updatedState.currentMachine!.id;
      } else {
        // Se não conseguir obter uma máquina, mostrar erro ao usuário
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma máquina encontrada para este dispositivo. Configure uma máquina primeiro.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          // Navegar para a página de configuração de máquinas
          Navigator.of(context).pushNamed('/registro-maquina');
          return;
        }
      }
    }

    Navigator.of(context).pushNamed(
      '/machine-current-config',
      arguments: {
        'registroMaquinaId': registroMaquinaId,
        'deviceId': deviceId,
        'userId': userId ?? 'unknown_user',
      },
    );
  }

  void _navigateToInjection() {
    Navigator.of(context).pushNamed('/injection');
  }

  void _navigateToHistory() {
    Navigator.of(context).pushNamed('/history');
  }

  void _navigateToSettings() {
    Navigator.of(context).pushNamed('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GP Máquina'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _navigateToSettings();
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configurações'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<InjectionBloc>().add(
              const InjectionLoadCurrentActiveProcess(),
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saudação
                _buildGreetingSection(),
                const SizedBox(height: 24),

                // Status do processo atual
                _buildCurrentProcessSection(),
                const SizedBox(height: 24),

                // Dashboard cards
                _buildDashboardSection(),
                const SizedBox(height: 24),

                // Ações rápidas
                _buildQuickActionsSection(),
                const SizedBox(height: 24),

                // Estatísticas recentes ocultadas
                // _buildRecentStatsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.precision_manufacturing,
            size: 48,
            color: AppColors.textOnPrimary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo!',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                Text(
                  'Sistema de Controle de Vulcanização',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentProcessSection() {
    return BlocBuilder<InjectionBloc, InjectionState>(
      builder: (context, state) {
        if (state is InjectionActiveProcessLoaded && state.processo != null) {
          return ProcessStatusCard(processo: state.processo!);
        } else if (state is InjectionNoActiveProcess) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nenhum processo ativo no momento',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                CustomButton(
                  text: 'Iniciar',
                  onPressed: _navigateToInjection,
                  size: ButtonSize.small,
                ),
              ],
            ),
          );
        } else if (state is InjectionLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visão Geral', style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
          children: [
            DashboardCard(
              title: 'Máquinas',
              subtitle: 'Gerenciar carcaças e matrizes',
              icon: Icons.precision_manufacturing,
              color: AppColors.primary,
              onTap: _navigateToMachines,
            ),
            DashboardCard(
              title: 'Vulcanização',
              subtitle: 'Controlar processos',
              icon: Icons.play_circle_filled,
              color: AppColors.success,
              onTap: _navigateToInjection,
            ),
            DashboardCard(
              title: 'Histórico',
              subtitle: 'Ver relatórios',
              icon: Icons.history,
              color: AppColors.info,
              onTap: _navigateToHistory,
            ),
            DashboardCard(
              title: 'Configurações',
              subtitle: 'Ajustar sistema',
              icon: Icons.settings,
              color: AppColors.warning,
              onTap: _navigateToSettings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return QuickActionsSection(
      onStartInjection: _navigateToInjection,
      onViewMachines: _navigateToMachines,
      onViewHistory: _navigateToHistory,
    );
  }

  Widget _buildRecentStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estatísticas Recentes', style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildStatRow('Processos Hoje', '12', Icons.today),
              const Divider(),
              _buildStatRow('Processos Concluídos', '8', Icons.check_circle),
              const Divider(),
              _buildStatRow('Taxa de Sucesso', '92%', Icons.trending_up),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Text(
          value,
          style: AppTextStyles.dataMedium.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}