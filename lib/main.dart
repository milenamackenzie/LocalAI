import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'injection_container.dart' as di;
import 'presentation/blocs/theme_bloc.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const LocalAIApp());
}

class LocalAIApp extends StatefulWidget {
  const LocalAIApp({super.key});

  @override
  State<LocalAIApp> createState() => _LocalAIAppState();
}

class _LocalAIAppState extends State<LocalAIApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(AppStarted());
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (context) => sl<BookmarkBloc>()),
        BlocProvider(create: (context) => sl<ReviewBloc>()),
        BlocProvider(create: (context) => sl<ThemeBloc>()),
        BlocProvider(create: (context) => sl<UserHubBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Re-build router logic if needed or use a listener
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              // Trigger router refresh on auth state change
              _router.refresh();
            },
            child: MaterialApp.router(
              title: 'LocalAI',
              debugShowCheckedModeBanner: false,
              themeMode: themeState.themeMode,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              routerConfig: _router,
            ),
          );
        },
      ),
    );
  }
}
