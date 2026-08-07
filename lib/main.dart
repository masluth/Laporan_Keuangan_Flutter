import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase initialization note: $e (Falling back to in-memory mode)',
    );
  }

  // Supabase
  await Supabase.initialize(
    url: 'https://rlfzktdllyorqdshwkuf.supabase.co/rest/v1/',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsZnprdGRsbHlvcnFkc2h3a3VmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYxMTMwNzEsImV4cCI6MjEwMTY4OTA3MX0.wYHHu5ZJkZlWWHezwzdc-1xTA6IDyOdaXLABjz-TVpg',
  );

  runApp(
    const ProviderScope(
      child: RevenantFinanceApp(),
    ),
  );
}

class RevenantFinanceApp extends ConsumerWidget {
  const RevenantFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Revenant Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}