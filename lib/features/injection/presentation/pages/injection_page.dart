import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import 'pesquisa_carcaca_page.dart';

class InjectionPage extends StatelessWidget {
  const InjectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Injeção'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 
                         kToolbarHeight - 48, // AppBar height + padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Icon(
              Icons.air,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sistema de Injeção de Ar',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Controle automatizado para injeção de ar em carcaças',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Iniciar Processo',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PesquisaCarcacaPage(),
                    ),
                  );
                },
                variant: ButtonVariant.filled,
                size: ButtonSize.large,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Histórico',
                onPressed: () {
                  // TODO: Implementar navegação para histórico
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Histórico em desenvolvimento'),
                    ),
                  );
                },
                variant: ButtonVariant.outlined,
                size: ButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}