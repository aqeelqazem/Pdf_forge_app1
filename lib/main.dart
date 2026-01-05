import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/app_router.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/business_logic/pdf_library_cubit.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
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
            // Use context.read instead of context.watch to prevent unnecessary rebuilds
            // of the router. The router itself listens to the stream for changes.
            final imageCubit = context.read<ImageCubit>();
            final appRouter = AppRouter(imageCubit: imageCubit);

            return MaterialApp.router(
              routerConfig: appRouter.router,
              debugShowCheckedModeBanner: false,
              title: 'PDF Genius',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
            );
          },
        ),
      ),
    );
  }
}
