// lib/main.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Main application entry point with Material Design 3 theming and BLoC setup
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

// Core imports - attempting to use our centralized constants and enums
import 'package:gameconsentbasic/core/constants/app_constants.dart';
import 'package:gameconsentbasic/core/enums/app_enums.dart';

// Feature imports - presentation layer screens for navigation
import 'package:gameconsentbasic/features/role_selection/presentation/pages/role_selection_page.dart';
import 'package:gameconsentbasic/features/permissions/presentation/pages/permissions_page.dart';
import 'package:gameconsentbasic/features/session_management/presentation/pages/gm_session_setup_page.dart';
import 'package:gameconsentbasic/features/session_management/presentation/pages/player_session_join_page.dart';

/// Main application entry point
/// This function is attempting to initialize the Flutter app with proper setup
void main() async {
  // Ensure Flutter framework is properly initialized before running the app
  // This is trying to handle any async initialization requirements
  WidgetsFlutterBinding.ensureInitialized();

  // Set up system UI overlay style for consistent appearance
  // Attempting to use Material Design 3 recommendations for status bar theming
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize logging for debugging and development
  // This logger instance is meant to help with troubleshooting during development
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Log application startup for debugging purposes
  // This logging is trying to track app initialization in development
  if (AppConstants.isDebugMode) {
    logger.i('🚀 Starting Game Consent Basic App v${AppConstants.appVersion}');
    logger.d(
      '📱 Target Platform: Android (Flutter ${AppConstants.appVersion})',
    );
    logger.d('🔵 Bluetooth P2P Mode: Free Version');
  }

  // Run the main application widget
  // This is attempting to start the Flutter widget tree with proper error handling
  runApp(GameConsentApp(logger: logger));
}

/// Main application widget class
/// This class is trying to set up the root widget with BLoC providers and theming
class GameConsentApp extends StatelessWidget {
  /// Constructor for GameConsentApp with optional logger injection
  /// This constructor is attempting to support dependency injection for testing
  const GameConsentApp({super.key, required this.logger});

  /// Logger instance for debugging and error tracking
  /// This logger is meant to be passed down through the widget tree as needed
  final Logger logger;

  @override
  Widget build(BuildContext context) {
    // Return MultiBlocProvider to set up state management for the entire app
    // This is attempting to provide BLoC instances to all child widgets
    return MultiBlocProvider(
      providers: [
        // TODO: Add BLoC providers here as we create them
        // These providers are meant to be available throughout the app widget tree

        // BlocProvider<BluetoothBloc>(
        //   create: (context) => BluetoothBloc()..add(BluetoothInitializeEvent()),
        // ),

        // BlocProvider<ConsentRatingBloc>(
        //   create: (context) => ConsentRatingBloc(),
        // ),

        // BlocProvider<SessionFeedbackBloc>(
        //   create: (context) => SessionFeedbackBloc(),
        // ),
      ],
      child: MaterialApp(
        // Application metadata and configuration
        title: AppConstants.appName,
        debugShowCheckedModeBanner: AppConstants.isDebugMode,

        // Material Design 3 theme configuration
        // This theme is attempting to use GameConsent brand colors and modern design
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system, // Respect user's system theme preference
        // Initial route and navigation setup
        // This is trying to start with the role selection screen
        initialRoute: '/',
        routes: {
          '/': (context) => const RoleSelectionPage(),
          '/gm-permissions': (context) =>
              const PermissionsPage(userRole: UserRole.gameMaster),
          '/player-permissions': (context) =>
              const PermissionsPage(userRole: UserRole.player),
          '/gm-session-setup': (context) => const GMSessionSetupPage(),
          '/player-session-join': (context) => const PlayerSessionJoinPage(),
        },

        // Global error handling and logging
        // This builder is attempting to catch and handle navigation errors
        builder: (context, child) {
          // Set up global error boundary for better crash reporting
          return _ErrorBoundary(
            logger: logger,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// Build light theme with GameConsent branding
  /// This method is attempting to create a cohesive visual identity
  ThemeData _buildLightTheme() {
    // Define custom color scheme based on traffic light colors
    // Trying to incorporate the green/yellow/red consent system into app theming
    const ColorScheme colorScheme = ColorScheme.light(
      primary: Color(0xFF4CAF50), // Green from ConsentRating.green
      secondary: Color(0xFFFF9800), // Yellow from ConsentRating.yellow
      error: Color(0xFFE53935), // Red from ConsentRating.red
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF212121),
    );

    return ThemeData(
      useMaterial3: true, // Enable Material Design 3 features in Flutter 3.32.x
      colorScheme: colorScheme,

      // App bar theming for consistent navigation
      // This is attempting to match the GameConsent visual identity
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Elevated button theming for primary actions
      // Trying to make buttons visually prominent and accessible
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card theming for consistent content containers
      // This is attempting to provide clean, elevated content areas
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.all(AppConstants.spacingMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Text theme for consistent typography
      // Trying to ensure good readability across all text elements
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF616161),
        ),
      ),
    );
  }

  /// Build dark theme with GameConsent branding
  /// This method is attempting to provide a dark mode alternative
  ThemeData _buildDarkTheme() {
    // Define dark color scheme maintaining traffic light accent colors
    // Trying to preserve brand identity while supporting dark theme preference
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: Color(0xFF66BB6A), // Lighter green for dark backgrounds
      secondary: Color(0xFFFFB74D), // Lighter yellow for dark backgrounds
      error: Color(0xFFEF5350), // Lighter red for dark backgrounds
      surface: Color(0xFF121212),
      onSurface: Color(0xFFE0E0E0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,

      // Dark theme app bar configuration
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFE0E0E0),
        elevation: 2,
        centerTitle: true,
      ),
    );
  }
}

/// Error boundary widget for global error handling
/// This widget is attempting to catch and gracefully handle runtime errors
class _ErrorBoundary extends StatelessWidget {
  const _ErrorBoundary({required this.logger, required this.child});

  final Logger logger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Global error handler for Flutter framework errors
/// This function is trying to provide better error reporting and recovery
void _handleFlutterError(FlutterErrorDetails details) {
  // Log the error for debugging purposes
  if (AppConstants.isDebugMode) {
    final Logger logger = Logger();
    logger.e('Flutter Error: ${details.exception}');
    logger.e('Stack Trace: ${details.stack}');
  }

  // In production, you might want to send this to a crash reporting service
  // For now, we'll just ensure the app continues running
  FlutterError.dumpErrorToConsole(details);
}
