import 'package:flutter/material.dart';
import '../../../injection/domain/entities/processo_injecao.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

/// Widget de card para mostrar o status do processo atual
class ProcessStatusCard extends StatelessWidget {
  final ProcessoInjecao processo;

  const ProcessStatusCard({
    super.key,
    required this.processo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
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
                'Processo Ativo',
                style: AppTextStyles.titleMedium,
              ),
              const Spacer(),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 16),

          // Informações do processo
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'ID',
                  '#${processo.id}',
                  Icons.tag,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Carcaça',
                  processo.carcacaCodigo,
                  Icons.precision_manufacturing,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Pressão Inicial',
                  '${processo.pressaoInicial.toStringAsFixed(1)} bar',
                  Icons.speed,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Tempo',
                  _formatDuration(processo.tempoDecorrido),
                  Icons.timer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ações
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ver Detalhes',
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/injection/process/${processo.id}',
                    );
                  },
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.small,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: _getActionText(),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/injection');
                  },
                  size: ButtonSize.small,
                  backgroundColor: _getStatusColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption,
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (processo.status) {
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
      default:
        return AppColors.textSecondary;
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

  String _getActionText() {
    switch (processo.status) {
      case StatusProcesso.injetando:
        return 'Pausar';
      case StatusProcesso.pausado:
        return 'Retomar';
      case StatusProcesso.aguardando:
      case StatusProcesso.iniciando:
        return 'Cancelar';
      default:
        return 'Visualizar';
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
}