import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/app_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _biometricEnabled = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleBiometricLogin() {
    AppLogger.ui('Toque em "Entrar com biometria"', name: 'Biometric');
    context.read<AuthBloc>().add(const AuthBiometricLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (state is AuthUnauthenticated && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(
                  400, // Altura mínima segura
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Center(
                      child: Image.asset(
                        'assets/images/gp_logo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Sistema de Controle de Vulcanização',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Formulário
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Usuário',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o usuário';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a senha';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botões
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return Column(
                        children: [
                          CustomButton(
                            text: 'Entrar',
                            onPressed: isLoading ? null : _handleLogin,
                            isLoading: isLoading,
                            size: ButtonSize.large,
                            width: double.infinity,
                            backgroundColor: AppColors.primaryDark,
                            textColor: AppColors.textOnPrimary,
                          ),
                          // const SizedBox(height: 12),
                          // CustomButton(
                          //   text: 'Entrar com biometria',
                          //   onPressed:
                          //       isLoading ||
                          //           AppConstants.biometricsGloballyDisabled
                          //       ? null
                          //       : _handleBiometricLogin,
                          //   isLoading: false,
                          // ),
                          // const SizedBox(height: 12),
                          // SwitchListTile(
                          //   title: const Text('Habilitar login por biometria'),
                          //   subtitle: AppConstants.biometricsGloballyDisabled
                          //       ? const Text(
                          //           'Biometria desativada temporariamente',
                          //         )
                          //       : null,
                          //   value: _biometricEnabled,
                          //   onChanged:
                          //       isLoading ||
                          //           AppConstants.biometricsGloballyDisabled
                          //       ? null
                          //       : (value) {
                          //           setState(() {
                          //             _biometricEnabled = value;
                          //           });
                          //           AppLogger.ui(
                          //             'Alterado switch biometria para: $value',
                          //             name: 'Biometric',
                          //           );
                          //           context.read<AuthBloc>().add(
                          //             AuthSetBiometricEnabled(value),
                          //           );
                          //         },
                          // ),
                        ],
                      );
                    },
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
