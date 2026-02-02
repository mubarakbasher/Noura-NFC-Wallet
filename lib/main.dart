import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart' as di;
import 'core/config/environment.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/nfc/nfc_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';
import 'presentation/bloc/wallet/wallet_event.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  // Override via --dart-define=ENV=production for release builds
  const envString = String.fromEnvironment('ENV', defaultValue: 'development');
  final env = switch (envString) {
    'production' => Environment.production,
    'staging' => Environment.staging,
    _ => Environment.development,
  };
  EnvironmentConfig.init(env);
  
  // Initialize dependencies
  await di.initializeDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<LocaleProvider>()),
        BlocProvider(create: (context) => di.sl<NfcBloc>()),
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => di.sl<WalletBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<TransactionBloc>(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'NFC Wallet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Unauthenticated) {
                  // Reset wallet state when user logs out
                  context.read<WalletBloc>().add(ResetWallet());
                }
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return const DashboardScreen();
                  } else if (state is Unauthenticated || state is AuthError || state is RegistrationSuccess) {
                    return const LoginScreen();
                  }
                  // Show loading while checking auth status
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
