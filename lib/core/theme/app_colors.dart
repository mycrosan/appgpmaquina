import 'package:flutter/material.dart';

/// Cores da aplicação
class AppColors {
  AppColors._();

  // Cores primárias
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Cores secundárias
  static const Color secondary = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF66BB6A);
  static const Color secondaryDark = Color(0xFF1B5E20);

  // Cores de superfície
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Cores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Cores de borda
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = Color(0xFF1976D2);

  // Cores de sombra
  static const Color shadow = Color(0x1A000000);

  // Cores específicas do domínio
  static const Color injectionActive = Color(0xFF4CAF50);
  static const Color injectionPaused = Color(0xFFFF9800);
  static const Color injectionCanceled = Color(0xFFF44336);
  static const Color injectionCompleted = Color(0xFF2196F3);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}