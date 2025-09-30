import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/widgets/splash_screen.dart';
import 'core/widgets/auth_wrapper.dart';
import 'core/config/app_config.dart';

import 'core/utils/app_logger.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/machine/presentation/bloc/machine_bloc.dart';
import 'features/machine/presentation/bloc/machine_config_bloc.dart';
import 'features/machine/presentation/bloc/configuracao_maquina_bloc.dart';
import 'features/machine/presentation/bloc/registro_maquina_bloc.dart';
import 'features/injection/presentation/bloc/injection_bloc.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/injection/presentation/pages/history_page.dart';
import 'features/machine/presentation/pages/machines_page.dart';
import 'features/machine/presentation/pages/machine_config_page.dart';
// Importação removida - página consolidada na MachineConfigPage
import 'features/machine/presentation/pages/registro_maquina_create_page.dart';
import 'features/injection/presentation/pages/injection_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable all debug visual aids
  debugPaintSizeEnabled = false;
  debugRepaintRainbowEnabled = false;

  // Initialize app configuration
  AppConfig.initialize();

  // Print environment info for debugging
  final config = AppConfig.instance;
  AppLogger.info('Iniciando GP Máquina');
  AppLogger.info('Ambiente: ${config.environment}');
  AppLogger.info('API URL: ${config.apiBaseUrl}');
  AppLogger.info('Produção: ${config.isProduction}');

  // Validate configuration
  if (!config.isValid) {
    AppLogger.error('ERRO: Configuração inválida!');
    AppLogger.debug('Debug Info: ${config.debugInfo}');
  }

  // Initialize dependencies
  await di.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<MachineBloc>(create: (context) => di.sl<MachineBloc>()),
        BlocProvider<MachineConfigBloc>(
          create: (context) => di.sl<MachineConfigBloc>(),
        ),
        BlocProvider<ConfiguracaoMaquinaBloc>(
          create: (context) => di.sl<ConfiguracaoMaquinaBloc>(),
        ),
        BlocProvider<RegistroMaquinaBloc>(
          create: (context) => di.sl<RegistroMaquinaBloc>(),
        ),
        BlocProvider<InjectionBloc>(
          create: (context) => di.sl<InjectionBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'GP Premium - Máquina',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          textTheme: TextTheme(
            displayLarge: AppTextStyles.headlineLarge,
            displayMedium: AppTextStyles.headlineMedium,
            displaySmall: AppTextStyles.headlineSmall,
            headlineMedium: AppTextStyles.headlineMedium,
            headlineSmall: AppTextStyles.headlineSmall,
            titleLarge: AppTextStyles.titleLarge,
            titleMedium: AppTextStyles.titleMedium,
            titleSmall: AppTextStyles.titleSmall,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
            bodySmall: AppTextStyles.bodySmall,
            labelLarge: AppTextStyles.labelLarge,
            labelMedium: AppTextStyles.labelMedium,
            labelSmall: AppTextStyles.labelSmall,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const AuthWrapper(),
          '/machines': (context) => const MachinesPage(),
          '/machine-register': (context) => const RegistroMaquinaCreatePage(),
          '/injection': (context) => const InjectionPage(),
          '/settings': (context) => const SettingsPage(),
          '/history': (context) => const HistoryPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/machine-config') {
            final args = settings.arguments as Map<String, String>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => MachineConfigPage(
                  deviceId: args['deviceId']!,
                  userId: args['userId']!,
                ),
              );
            }
          } else if (settings.name == '/machine-current-config') {
            // Redirecionando para machine-config
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => MachineConfigPage(
                  registroMaquinaId: args['registroMaquinaId'] as int,
                  deviceId: args['deviceId'] as String? ?? 'unknown_device',
                  userId: args['userId'] as String? ?? 'unknown_user',
                ),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
