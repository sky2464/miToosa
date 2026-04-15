import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/design_system.dart';
import 'features/auth/login_screen.dart';

import 'data/hive_persistence_provider.dart';
import 'core/content_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ContentProvider().init();
  await HivePersistenceProvider().init();

  runApp(
    const ProviderScope(
      child: MiToosaApp(),
    ),
  );
}

class MiToosaApp extends StatelessWidget {
  const MiToosaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'miToosa',
      theme: MiToosaTheme.lightTheme,
      darkTheme: MiToosaTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
