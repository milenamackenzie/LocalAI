import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/theme_bloc.dart';
import 'presentation/blocs/bookmark_bloc.dart';
import 'presentation/blocs/review_bloc.dart';
import 'presentation/blocs/user_hub_bloc.dart';
import 'core/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  // Ensure Flutter framework is fully initialised
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const LocalAIApp());
}

class LocalAIApp extends StatelessWidget {
  const LocalAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (_) => di.sl<ThemeBloc>()),
        BlocProvider(create: (_) => di.sl<BookmarkBloc>()),
        BlocProvider(create: (_) => di.sl<ReviewBloc>()),
        BlocProvider(create: (_) => di.sl<UserHubBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final authBloc = context.read<AuthBloc>();
          return MaterialApp.router(
            title: 'LocalAI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            routerConfig: AppRouter.createRouter(authBloc),
          );
        },
      ),
    );
  }
}
