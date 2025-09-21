// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alice/alice.dart' as _i917;
import 'package:alice_dio/alice_dio_adapter.dart' as _i433;
import 'package:example_bps_sso/core/di/injection.dart' as _i637;
import 'package:example_bps_sso/routes/app_router.dart' as _i729;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i917.Alice>(() => registerModule.alice());
    gh.lazySingleton<_i729.AppRouter>(() => registerModule.appRouter());
    gh.singleton<_i433.AliceDioAdapter>(
      () => registerModule.aliceDioAdapter(gh<_i917.Alice>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i637.RegisterModule {}
