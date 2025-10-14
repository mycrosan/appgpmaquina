## ProGuard rules for Flutter Android release builds
## The Flutter Gradle plugin already supplies necessary keep rules.
## You can add project-specific rules below as needed.

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# (Opcional) Se você usa bibliotecas que dependem de reflexão, adicione regras específicas aqui.

# Evita falhas do R8 por classes usadas opcionalmente pelo Flutter para Deferred Components
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }