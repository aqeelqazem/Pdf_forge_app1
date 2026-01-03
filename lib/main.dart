
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app_router.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ImageCubit _imageCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _imageCubit = ImageCubit();
    _imageCubit.loadInitialSession();
    _appRouter = AppRouter(imageCubit: _imageCubit);
  }

  @override
  void dispose() {
    _imageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _imageCubit,
      child: MaterialApp.router(
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
        title: 'PDF Genius',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
