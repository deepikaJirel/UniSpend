import 'package:flutter/material.dart';

import 'screens/unispend_shell.dart';
import 'theme/app_theme.dart';

class UniSpendApp extends StatelessWidget {
  const UniSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSpend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const UniSpendShell(),
    );
  }
}
