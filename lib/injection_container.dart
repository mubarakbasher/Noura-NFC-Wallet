import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core
import 'core/network/api_client.dart';

// Data sources
import 'data/datasources/nfc_channel_datasource.dart';

// Repositories
import 'data/repositories/nfc_repository_impl.dart';

// Domain repositories
import 'domain/repositories/nfc_repository.dart';

// BLoCs
import 'presentation/bloc/nfc/nfc_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';

// Localization
import 'core/localization/locale_provider.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  sl.registerLazySingleton(() => ApiClient(sl()));

  // Data sources
  sl.registerLazySingleton(() => NfcChannelDatasource());

  // Repositories
  sl.registerLazySingleton<NfcRepository>(
    () => NfcRepositoryImpl(sl()),
  );

  // Use cases
  // Will be added later

  // Providers
  sl.registerLazySingleton(() => LocaleProvider(sl()));

  // BLoCs
  sl.registerFactory(() => NfcBloc(nfcRepository: sl()));
  sl.registerFactory(() => AuthBloc(sharedPreferences: sl()));
  sl.registerFactory(() => WalletBloc());
}
