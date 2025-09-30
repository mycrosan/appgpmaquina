import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Widget de seção de ações rápidas
class QuickActionsSection extends StatelessWidget {
  final VoidCallback? onStartInjection;
  final VoidCallback? onViewMachines;
  final VoidCallback? onViewHistory;

  const QuickActionsSection({
    super.key,
    this.onStartInjection,
    this.onViewMachines,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ações Rápidas', style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Novo Processo',
                'Iniciar nova injeção',
                Icons.play_arrow,
                AppColors.primary,
                () {
                  if (onStartInjection != null) {
                    onStartInjection!();
                  } else {
                    _navigateToNewProcess(context);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Histórico',
                'Ver processos anteriores',
                Icons.history,
                AppColors.secondary,
                () {
                  if (onViewHistory != null) {
                    onViewHistory!();
                  } else {
                    _navigateToHistory(context);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Configurações',
                'Ajustar parâmetros',
                Icons.settings,
                AppColors.textSecondary,
                () {
                  if (onViewMachines != null) {
                    onViewMachines!();
                  } else {
                    _navigateToSettings(context);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Relatórios',
                'Visualizar estatísticas',
                Icons.analytics,
                AppColors.info,
                () => _navigateToReports(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.titleSmall),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNewProcess(BuildContext context) {
    // TODO: Implementar navegação para nova injeção
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegação para novo processo em desenvolvimento'),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    // TODO: Implementar navegação para histórico
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegação para histórico em desenvolvimento'),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Implementar navegação para configurações
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegação para configurações em desenvolvimento'),
      ),
    );
  }

  void _navigateToReports(BuildContext context) {
    // TODO: Implementar navegação para relatórios
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegação para relatórios em desenvolvimento'),
      ),
    );
  }
}