// lib/main.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Main app with Role Selection page
// Author: Hawke Robinson

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import the pages
import 'package:gameconsentbasic/features/role_selection/presentation/pages/role_selection_page.dart';
import 'package:gameconsentbasic/features/permissions/presentation/pages/permissions_page.dart';
import 'package:gameconsentbasic/features/session_management/presentation/pages/gm_session_setup_page.dart';
import 'package:gameconsentbasic/features/session_management/presentation/pages/player_session_join_page.dart';
import 'package:gameconsentbasic/core/enums/app_enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  print('🚀 Starting Game Consent Basic App v0.0.1+005251130');

  runApp(const GameConsentApp());
}

class GameConsentApp extends StatelessWidget {
  const GameConsentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Consent Basic',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4CAF50), // Green
          secondary: Color(0xFFFF9800), // Yellow
          error: Color(0xFFE53935), // Red
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),

      // Start with Role Selection page
      home: const RoleSelectionPage(),

      // Define routes (we'll test these one by one)
      routes: {
        '/role-selection': (context) => const RoleSelectionPage(),
        '/gm-permissions': (context) =>
            const PermissionsPage(userRole: UserRole.gameMaster),
        '/player-permissions': (context) =>
            const PermissionsPage(userRole: UserRole.player),
        '/gm-session-setup': (context) => const GMSessionSetupPage(),
        '/player-session-join': (context) => const PlayerSessionJoinPage(),
      },
    );
  }
}
