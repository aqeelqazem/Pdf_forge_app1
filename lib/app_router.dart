
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/business_logic/image_cubit.dart';
import 'package:myapp/ui/screens/about_screen.dart';
import 'package:myapp/ui/screens/image_display_screen.dart';
import 'package:myapp/ui/screens/home_screen.dart';
import 'package:myapp/ui/screens/image_edit_screen.dart';

// Helper class to make GoRouter listen to Bloc stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final ImageCubit imageCubit;

  AppRouter({required this.imageCubit});

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(imageCubit.stream),
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'about',
            builder: (BuildContext context, GoRouterState state) {
              return const AboutScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/display',
        builder: (BuildContext context, GoRouterState state) {
          return const ImageDisplayScreen();
        },
      ),
      GoRoute(
        path: '/edit',
        builder: (BuildContext context, GoRouterState state) {
          return const ImageEditScreen();
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool hasImages = imageCubit.state.pickedImages.isNotEmpty;
      final String displayLocation = '/display';
      final String editLocation = '/edit';

      // If the user is trying to go to the editor but has no images,
      // redirect them to the home page.
      if (!hasImages && (state.matchedLocation == displayLocation || state.matchedLocation == editLocation)) {
        return '/';
      }

      // If no redirect is needed, return null.
      return null;
    },
  );
}
