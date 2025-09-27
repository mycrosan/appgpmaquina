import 'package:flutter/material.dart';
import '../../domain/entities/processo_injecao.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Widget de card para exibir um processo no histórico
class ProcessHistoryCard extends StatelessWidget {
  final ProcessoInjecao processo;
  final VoidCallback? onTap;

  const ProcessHistoryCard({
    super.key,
    required this.processo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            // Cabeçalho
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Processo #${processo.id}',
                  style: AppTextStyles.titleSmall,
                ),
                const Spacer(),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 12),

            // Informações principais
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Carcaça',
                    processo.carcacaCodigo,
                    Icons.precision_manufacturing,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Matriz',
                    processo.matrizNome,
                    Icons.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dados do processo
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Pressão Final',
                    '${processo.pressaoAtual.toStringAsFixed(1)} PSI',
                    Icons.speed,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Duração',
                    _formatDuration(processo.tempoDecorrido),
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Data e usuário
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Iniciado em',
                    _formatDateTime(processo.iniciadoEm),
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Operador',
                    processo.userName,
                    Icons.person,
                  ),
                ),
              ],
            ),

            // Observações (se houver)
            if (processo.observacoes != null && processo.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observações',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      processo.observacoes!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],

            // Motivo do erro (se houver)
            if (processo.motivoErro != null && processo.motivoErro!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Motivo do Erro',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      processo.motivoErro!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(),
        style: AppTextStyles.labelSmall.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (processo.status) {
      case StatusProcesso.aguardando:
        return AppColors.warning;
      case StatusProcesso.iniciando:
      case StatusProcesso.injetando:
        return AppColors.injectionActive;
      case StatusProcesso.pausado:
        return AppColors.injectionPaused;
      case StatusProcesso.cancelado:
        return AppColors.injectionCanceled;
      case StatusProcesso.concluido:
        return AppColors.injectionCompleted;
      case StatusProcesso.erro:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (processo.status) {
      case StatusProcesso.aguardando:
        return 'Aguardando';
      case StatusProcesso.iniciando:
        return 'Iniciando';
      case StatusProcesso.injetando:
        return 'Em Andamento';
      case StatusProcesso.pausado:
        return 'Pausado';
      case StatusProcesso.cancelado:
        return 'Cancelado';
      case StatusProcesso.concluido:
        return 'Concluído';
      case StatusProcesso.erro:
        return 'Erro';
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}