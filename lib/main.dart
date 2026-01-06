
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app_router.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/business_logic/pdf_library_cubit.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => PdfService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ImageCubit()..loadInitialSession(),
          ),
          BlocProvider(
            create: (context) => PdfLibraryCubit(context.read<PdfService>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final imageCubit = context.read<ImageCubit>();
            final appRouter = AppRouter(imageCubit: imageCubit);

            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp.router(
                  routerConfig: appRouter.router,
                  debugShowCheckedModeBanner: false,
                  title: 'PDF Genius',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
