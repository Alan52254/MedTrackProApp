import 'package:flutter/material.dart';

import 'shell/app_shell.dart';

abstract final class AppRoutes {
  static const String root = '/';
}

abstract final class AppRouter {
  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    AppRoutes.root: (_) => const AppShell(),
  };
}
