import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/injection_bloc.dart';
import 'detalhes_carcaca_page.dart';

class PesquisaCarcacaPage extends StatefulWidget {
  const PesquisaCarcacaPage({super.key});

  @override
  State<PesquisaCarcacaPage> createState() => _PesquisaCarcacaPageState();
}

class _PesquisaCarcacaPageState extends State<PesquisaCarcacaPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroEtiquetaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroEtiquetaController.dispose();
    super.dispose();
  }

  void _validarCarcaca() async {
    if (_formKey.currentState?.validate() ?? false) {
      final numeroEtiqueta = _numeroEtiquetaController.text.trim();
      
      // Obter deviceId real do dispositivo
      String deviceId = 'unknown_device';
      const userId = 'user-001'; // TODO: Obter userId do contexto/storage
      
      try {
        deviceId = await DeviceInfoService.instance.getDeviceId();
        print('[VALIDAR_CARCACA] 📱 Device ID obtido: $deviceId');
      } catch (e) {
        print('[VALIDAR_CARCACA] ❌ Erro ao obter Device ID: $e');
        // Usar fallback
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      }

      context.read<InjectionBloc>().add(
        InjectionValidarCarcaca(
          numeroEtiqueta: numeroEtiqueta,
          deviceId: deviceId,
          userId: userId,
        ),
      );
    }
  }

  void _limparCampo() {
    _numeroEtiquetaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Carcaça'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: BlocListener<InjectionBloc, InjectionState>(
        listener: (context, state) {
          if (state is InjectionLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is InjectionCarcacaValidada) {
            // Navegar para tela de detalhes
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetalhesCarcacaPage(
                  numeroEtiqueta: state.numeroEtiqueta,
                  matrizDescricao: state.matrizDescricao,
                  tempoInjecao: state.tempoInjecao,
                  isMatrizCompativel: state.isMatrizCompativel,
                ),
              ),
            );
          } else if (state is InjectionCarcacaValidationError) {
            // Mostrar erro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 32),
                
                // Ícone e título
                const Icon(
                  Icons.search,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Digite o número da etiqueta',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Informe os 6 dígitos da etiqueta da carcaça',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Campo de entrada
                CustomTextField(
                  controller: _numeroEtiquetaController,
                  label: 'Número da Etiqueta',
                  hint: '000000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o número da etiqueta';
                    }
                    if (value.length != 6) {
                      return 'O número deve ter exatamente 6 dígitos';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Auto-submit quando atingir 6 dígitos
                    if (value.length == 6) {
                      _validarCarcaca();
                    }
                  },
                ),
                const SizedBox(height: 32),
                
                // Botões
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Limpar',
                        onPressed: _isLoading ? null : _limparCampo,
                        variant: ButtonVariant.outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Pesquisar',
                        onPressed: _isLoading ? null : _validarCarcaca,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Instruções
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Instruções',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Digite os 6 dígitos da etiqueta\n'
                        '• A pesquisa será feita automaticamente\n'
                        '• Verifique se a matriz está correta',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}