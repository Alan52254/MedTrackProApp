import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class MedTrackProApp extends StatelessWidget {
  const MedTrackProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedTrack Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.root,
      routes: AppRouter.routes,
    );
  }
}
