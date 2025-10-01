import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/injection_bloc.dart';
import 'timer_injecao_page.dart';

class DetalhesCarcacaPage extends StatelessWidget {
  final String numeroEtiqueta;
  final String matrizDescricao;
  final int tempoInjecao;
  final bool isMatrizCompativel;

  const DetalhesCarcacaPage({
    super.key,
    required this.numeroEtiqueta,
    required this.matrizDescricao,
    required this.tempoInjecao,
    required this.isMatrizCompativel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Carcaça'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: BlocListener<InjectionBloc, InjectionState>(
        listener: (context, state) {
          if (state is InjectionInjecaoArEmAndamento) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TimerInjecaoPage(
                  numeroEtiqueta: numeroEtiqueta,
                  tempoInjecao: tempoInjecao,
                ),
              ),
            );
          } else if (state is InjectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card com informações da carcaça
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Etiqueta: $numeroEtiqueta',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                        'Matriz:',
                        matrizDescricao,
                        Icons.precision_manufacturing,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Tempo de Injeção:',
                        '${tempoInjecao}s',
                        Icons.timer,
                      ),
                      const SizedBox(height: 20),
                      // Status da matriz
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMatrizCompativel 
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMatrizCompativel 
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isMatrizCompativel 
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: isMatrizCompativel 
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                isMatrizCompativel
                                    ? 'Matriz compatível com a máquina'
                                    : 'Matriz incompatível com a máquina',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isMatrizCompativel 
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botões de ação
              if (isMatrizCompativel) ...[
                CustomButton(
                  text: 'Iniciar Injeção de Ar',
                  onPressed: () {
                    print('🖱️ [UI] Usuário clicou em "Iniciar Injeção de Ar"');
                    print('📋 [UI] Dados: etiqueta=$numeroEtiqueta, tempo=${tempoInjecao}s');
                    
                    try {
                      print('📤 [UI] Enviando evento InjectionIniciarInjecaoAr para o Bloc...');
                      context.read<InjectionBloc>().add(
                        InjectionIniciarInjecaoAr(
                          numeroEtiqueta: numeroEtiqueta,
                          tempoInjecao: tempoInjecao,
                        ),
                      );
                      print('✅ [UI] Evento enviado com sucesso');
                    } catch (e) {
                      print('💥 [UI] ERRO ao enviar evento para o Bloc: $e');
                    }
                  },
                  backgroundColor: AppColors.success,
                  icon: Icons.play_arrow,
                ),
                const SizedBox(height: 12),
              ],
              
              CustomButton(
                text: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: AppColors.border,
                textColor: AppColors.textPrimary,
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}