import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MachinesPage extends StatelessWidget {
  const MachinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Máquinas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.precision_manufacturing,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página de Máquinas',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Em desenvolvimento...',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/machine-register');
                },
                icon: const Icon(Icons.add),
                label: const Text('Registrar Nova Máquina'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/machine-config',
                    arguments: {
                      'deviceId': 'device_001', // Exemplo - deve vir de contexto real
                      'userId': 'user_001', // Exemplo - deve vir de contexto real
                    },
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Configurar Máquina'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/machine-current-config',
                    arguments: {
                      'registroMaquinaId': 1, // Exemplo - deve vir de contexto real
                      'deviceId': 'device_001', // Exemplo - deve vir de contexto real
                      'userId': 'user_001', // Exemplo - deve vir de contexto real
                    },
                  );
                },
                icon: const Icon(Icons.save_alt),
                label: const Text('Registrar Configuração Atual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}