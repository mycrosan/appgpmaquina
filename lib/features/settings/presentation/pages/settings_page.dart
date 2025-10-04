import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import 'relay_settings_page.dart';

/// Tela de configurações da aplicação
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Conta
            _buildSectionHeader('Conta'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Perfil do Usuário',
                'Editar informações pessoais',
                Icons.person,
                () => _navigateToProfile(context),
              ),
              _buildSettingsTile(
                'Alterar Senha',
                'Modificar senha de acesso',
                Icons.lock,
                () => _navigateToChangePassword(context),
              ),
              _buildSettingsTile(
                'Autenticação Biométrica',
                'Configurar login por biometria',
                Icons.fingerprint,
                () => _navigateToBiometric(context),
              ),
            ]),

            const SizedBox(height: 24),

            // Seção de Sistema
            _buildSectionHeader('Sistema'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Configuração de Rede',
                'Configurar conexão com API',
                Icons.wifi,
                () => _navigateToNetwork(context),
              ),
              _buildSettingsTile(
                'Configuração do Relé',
                'Configurar relé IoT (Tasmota)',
                Icons.electric_bolt,
                () => _navigateToRelay(context),
              ),
              _buildSettingsTile(
                'Backup e Sincronização',
                'Gerenciar dados locais',
                Icons.sync,
                () => _navigateToBackup(context),
              ),
            ]),

            const SizedBox(height: 24),

            // Seção de Aplicativo
            _buildSectionHeader('Aplicativo'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Notificações',
                'Configurar alertas e avisos',
                Icons.notifications,
                () => _navigateToNotifications(context),
              ),
              _buildSettingsTile(
                'Tema',
                'Personalizar aparência',
                Icons.palette,
                () => _navigateToTheme(context),
              ),
              _buildSettingsTile(
                'Sobre',
                'Informações do aplicativo',
                Icons.info,
                () => _navigateToAbout(context),
              ),
            ]),

            const SizedBox(height: 32),

            // Botão de Logout
            CustomButton(
              text: 'Sair da Conta',
              onPressed: () => _showLogoutDialog(context),
              variant: ButtonVariant.outlined,
              size: ButtonSize.large,
              icon: Icons.logout,
              textColor: AppColors.error,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _navigateToProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela de perfil em desenvolvimento')),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela de alteração de senha em desenvolvimento')),
    );
  }

  void _navigateToBiometric(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração biométrica em desenvolvimento')),
    );
  }

  void _navigateToNetwork(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração de rede em desenvolvimento')),
    );
  }

  void _navigateToRelay(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RelaySettingsPage(),
      ),
    );
  }

  void _navigateToBackup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup e sincronização em desenvolvimento')),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração de notificações em desenvolvimento')),
    );
  }

  void _navigateToTheme(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração de tema em desenvolvimento')),
    );
  }

  void _navigateToAbout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela sobre em desenvolvimento')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Saída',
            style: AppTextStyles.titleMedium,
          ),
          content: Text(
            'Tem certeza que deseja sair da sua conta?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: Text(
                'Sair',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}