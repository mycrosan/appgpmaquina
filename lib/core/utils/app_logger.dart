import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Logger customizado que exibe logs tanto no developer.log quanto no terminal
/// Útil para desenvolvimento quando queremos ver os logs no terminal
class AppLogger {
  static const String _defaultName = 'AppLogger';
  
  /// Log de informação
  static void info(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('ℹ️ $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] ℹ️ $message');
    }
  }
  
  /// Log de sucesso
  static void success(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('✅ $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] ✅ $message');
    }
  }
  
  /// Log de erro
  static void error(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('❌ $message', name: logName, error: error, stackTrace: stackTrace);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] ❌ $message');
      if (error != null) {
        print('[$logName] 💥 Error: $error');
      }
      if (stackTrace != null) {
        print('[$logName] 📍 StackTrace: $stackTrace');
      }
    }
  }
  
  /// Log de warning
  static void warning(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('⚠️ $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] ⚠️ $message');
    }
  }
  
  /// Log de debug
  static void debug(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('🐛 $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] 🐛 $message');
    }
  }
  
  /// Log de rede/API
  static void network(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('🌐 $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] 🌐 $message');
    }
  }
  
  /// Log de dados/resposta
  static void data(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('📊 $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] 📊 $message');
    }
  }
  
  /// Log de UI/interface
  static void ui(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('🎨 $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] 🎨 $message');
    }
  }
  
  /// Log de cache
  static void cache(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('💾 $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] 💾 $message');
    }
  }
  
  /// Log de autenticação
  static void auth(String message, {String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('🔐 $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] 🔐 $message');
    }
  }
  
  /// Log personalizado com emoji
  static void custom(String message, {String emoji = '📝', String? name}) {
    final logName = name ?? _defaultName;
    
    // Log no developer.log (aparece no DevTools)
    developer.log('$emoji $message', name: logName);
    
    // Log no terminal (aparece no console)
    if (kDebugMode) {
      print('[$logName] $emoji $message');
    }
  }
}