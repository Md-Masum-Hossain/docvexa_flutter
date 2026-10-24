import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/navigation/app_shell.dart';
import 'core/navigation/user_role.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DocvexaApp());
}

class DocvexaApp extends StatelessWidget {
  const DocvexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // The authenticated session will provide this role in the auth phase.
      home: const AppShell(role: UserRole.patient),
    );
  }
}
