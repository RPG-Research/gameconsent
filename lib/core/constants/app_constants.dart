// lib/core/constants/app_constants.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Core application constants and configuration values
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

/// This class is attempting to centralize all constant values used throughout
/// the Game Consent Basic App to maintain consistency and make configuration changes easier
class AppConstants {
  // Private constructor - this class is meant to be used as a static utility
  AppConstants._();

  /// Application metadata constants
  /// These values are trying to maintain version consistency across the app
  static const String appName = 'Game Consent Basic App';
  static const String appVersion = '0.0.1+005251130';
  static const String appDescription =
      'Real-time game session consent management';
  static const String developerName = 'Hawke Robinson - RPG Research';
  static const String officialWebsite = 'https://www.gameconsent.com';
  static const String githubRepository =
      'https://github.com/RPG-Research/gameconsent';
  static const String supportUrl = 'https://www.gameconsent.com/support';

  /// Bluetooth P2P connection constants
  /// This section is attempting to define the parameters for peer-to-peer connectivity
  static const String bluetoothServiceUuid = 'GameConsent-Service-UUID-2025';
  static const String bluetoothCharacteristicUuid =
      'GameConsent-Characteristic-UUID-2025';
  static const int bluetoothScanTimeoutSeconds = 30;
  static const int bluetoothConnectionTimeoutSeconds = 15;
  static const int maxPlayersPerSession =
      8; // Reasonable limit for Bluetooth P2P performance

  /// Session naming and security constants
  /// These values are trying to provide reasonable defaults for session management
  static const int sessionNameMinLength = 3;
  static const int sessionNameMaxLength = 50;
  static const int passwordMinLength = 4;
  static const int passwordMaxLength = 20;
  static const String defaultSessionPrefix = 'GameConsent Basic Session';

  /// Traffic light rating system constants
  /// This section is attempting to define the core consent rating values
  static const int greenRatingValue = 0; // All good, comfortable, proceed
  static const int yellowRatingValue = 1; // Caution, getting uncomfortable
  static const int redRatingValue = 2; // Stop, very uncomfortable

  /// UI/UX timing and animation constants
  /// These values are trying to provide smooth user experience timing
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Duration ratingUpdateDelay = Duration(milliseconds: 100);

  /// Screen size and responsive design constants
  /// This section is attempting to handle different device sizes appropriately
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  /// Padding and spacing constants for consistent UI
  /// These values are trying to maintain Material Design 3 spacing guidelines
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  /// D20 dice-shaped button constants
  /// This section is attempting to define the visual parameters for the traffic light buttons
  static const double d20ButtonSize = 80.0;
  static const double d20ButtonSizeSmall = 60.0;
  static const double d20ButtonSizeLarge = 100.0;
  static const double d20ButtonBorderWidth = 3.0;

  /// Session feedback and questionnaire constants
  /// These values are trying to structure the post-session feedback system
  static const int feedbackMinLength = 10;
  static const int feedbackMaxLength = 500;
  static const List<String> defaultFeedbackQuestions = [
    'How comfortable did you feel during this game session?',
    'Did the Game Master respond appropriately to consent signals?',
    'Would you use the Game Consent Basic App again in future sessions?',
    'Any additional feedback about the app or game session?',
  ];

  /// Error messages and user feedback constants
  /// This section is attempting to provide consistent messaging throughout the app
  static const String bluetoothNotAvailableError =
      'Bluetooth is not available on this device';
  static const String bluetoothPermissionDeniedError =
      'Bluetooth permission was denied';
  static const String connectionTimeoutError =
      'Connection timeout - please try again';
  static const String sessionNotFoundError = 'Game session not found';
  static const String invalidPasswordError = 'Invalid session password';
  static const String maxPlayersReachedError =
      'Maximum number of players reached';

  /// Success messages for positive user feedback
  /// These messages are trying to provide encouraging feedback to users
  static const String connectionSuccessMessage =
      'Successfully connected to game session';
  static const String sessionCreatedMessage =
      'Game session created successfully';
  static const String feedbackSubmittedMessage = 'Thank you for your feedback';

  /// Asset paths for images and icons
  /// This section is attempting to centralize asset path management
  static const String assetsPath = 'assets/';
  static const String imagesPath = '${assetsPath}images/';
  static const String iconsPath = '${assetsPath}icons/';
  static const String logosPath = '${assetsPath}logos/';

  /// Asset file names based on GameConsent.com resources
  /// These paths are trying to reference the visual assets you provided
  static const String trafficLightMockupImage =
      '${imagesPath}traffic_light_mockup.png';
  static const String loginBackgroundImage =
      '${imagesPath}login_background.png';
  static const String appIconPath = '${iconsPath}app_icon.png';
  static const String rpgResearchLogoPath = '${logosPath}rpg_research_logo.png';

  /// Logging and debugging constants
  /// This section is attempting to provide consistent logging levels
  static const String loggerName = 'GameConsentApp';
  static const bool isDebugMode =
      true; // This should be false for production builds

  /// Database and storage constants (for future versions)
  /// These values are meant to be placeholders for Standard/Pro/Enterprise versions
  static const String localStorageKey = 'game_consent_local_data';
  static const String sessionHistoryKey = 'session_history';
  static const String userPreferencesKey = 'user_preferences';
}
