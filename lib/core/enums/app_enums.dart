// lib/core/enums/app_enums.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Core application enumerations for type-safe state management
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

/// This file is attempting to define all the enumeration types used throughout
/// the Game Consent Basic App to ensure type safety and prevent invalid state combinations
library;

/// User role enumeration - defines whether the user is hosting or joining a session
/// This enum is trying to distinguish between the two primary user types in the app
enum UserRole {
  /// Game Master or Facilitator - the person hosting the GameConsent session
  /// This role is meant to have administrative control over the session
  gameMaster('Game Master/Facilitator', 'GM'),

  /// Player - someone joining an existing GameConsent session
  /// This role is meant to participate in the session but not control it
  player('Player', 'Player');

  /// Constructor for UserRole enum with display values
  const UserRole(this.displayName, this.shortName);

  /// Full display name for UI presentation
  final String displayName;

  /// Short name for compact UI elements
  final String shortName;

  /// Helper method to get user role from string (useful for serialization)
  /// This method is attempting to provide safe string-to-enum conversion
  static UserRole? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'gamemaster':
      case 'gm':
      case 'facilitator':
        return UserRole.gameMaster;
      case 'player':
        return UserRole.player;
      default:
        return null;
    }
  }
}

/// Consent rating enumeration - the core traffic light system values
/// This enum is trying to represent the three levels of comfort/consent
enum ConsentRating {
  /// Green light - comfortable, everything is okay, proceed
  /// This rating is meant to indicate full consent and comfort
  green(0, 'Green', 'Comfortable - Proceed', 0xFF4CAF50),

  /// Yellow light - caution, getting uncomfortable, slow down
  /// This rating is meant to indicate mild discomfort or need for caution
  yellow(1, 'Yellow', 'Caution - Uncomfortable', 0xFFFF9800),

  /// Red light - stop, very uncomfortable, change direction immediately
  /// This rating is meant to indicate serious discomfort requiring immediate attention
  red(2, 'Red', 'Stop - Very Uncomfortable', 0xFFE53935);

  /// Constructor for ConsentRating enum with display and color values
  const ConsentRating(this.value, this.name, this.description, this.colorValue);

  /// Numerical value for the rating (matches AppConstants)
  final int value;

  /// Short name for the rating
  final String name;

  /// Descriptive text for UI display
  final String description;

  /// Color value for UI theming (Material Design color palette)
  final int colorValue;

  /// Helper method to get consent rating from integer value
  /// This method is attempting to provide safe integer-to-enum conversion
  static ConsentRating? fromValue(int value) {
    switch (value) {
      case 0:
        return ConsentRating.green;
      case 1:
        return ConsentRating.yellow;
      case 2:
        return ConsentRating.red;
      default:
        return null;
    }
  }

  /// Helper method to get consent rating from string name
  /// This method is trying to provide safe string-to-enum conversion
  static ConsentRating? fromName(String name) {
    switch (name.toLowerCase()) {
      case 'green':
        return ConsentRating.green;
      case 'yellow':
        return ConsentRating.yellow;
      case 'red':
        return ConsentRating.red;
      default:
        return null;
    }
  }
}

/// Bluetooth connection state enumeration
/// This enum is attempting to track the various states of P2P connectivity
enum BluetoothConnectionState {
  /// Bluetooth is not available on this device
  /// This state is meant to indicate hardware/OS limitations
  unavailable('Unavailable', 'Bluetooth not available'),

  /// Bluetooth is available but not enabled
  /// This state is trying to prompt the user to enable Bluetooth
  disabled('Disabled', 'Bluetooth is disabled'),

  /// Bluetooth is enabled and ready for use
  /// This state is meant to indicate readiness for connection operations
  enabled('Enabled', 'Bluetooth is ready'),

  /// Currently scanning for available GameConsent sessions
  /// This state is trying to indicate active discovery process
  scanning('Scanning', 'Searching for sessions'),

  /// Found available sessions, waiting for user selection
  /// This state is meant to present discovered sessions to the user
  sessionsFound('Sessions Found', 'Sessions available'),

  /// Attempting to connect to a selected session
  /// This state is trying to indicate connection in progress
  connecting('Connecting', 'Connecting to session'),

  /// Successfully connected to a GameConsent session
  /// This state is meant to indicate active participation in a session
  connected('Connected', 'Connected to session'),

  /// Connection was lost or terminated
  /// This state is trying to indicate need for reconnection
  disconnected('Disconnected', 'Connection lost'),

  /// An error occurred during connection process
  /// This state is meant to indicate error conditions requiring user attention
  error('Error', 'Connection error occurred');

  /// Constructor for BluetoothConnectionState enum with display values
  const BluetoothConnectionState(this.name, this.description);

  /// Short name for the connection state
  final String name;

  /// Descriptive text for UI display and error messages
  final String description;
}

/// Game session state enumeration
/// This enum is attempting to track the lifecycle of a GameConsent session
enum GameSessionState {
  /// Initial state - no session created or joined yet
  /// This state is meant to represent the app startup condition
  idle('Idle', 'No active session'),

  /// Creating a new session as Game Master/Facilitator
  /// This state is trying to indicate session setup in progress
  creating('Creating', 'Setting up new session'),

  /// Session created and waiting for players to join
  /// This state is meant to indicate successful host setup
  waitingForPlayers('Waiting', 'Waiting for players'),

  /// Attempting to join an existing session as a player
  /// This state is trying to indicate join process in progress
  joining('Joining', 'Joining session'),

  /// Session is active with participants connected
  /// This state is meant to indicate normal operational mode
  active('Active', 'Session in progress'),

  /// Session is paused (for future functionality)
  /// This state is trying to support pause/resume capabilities
  paused('Paused', 'Session paused'),

  /// Session has ended normally
  /// This state is meant to indicate successful completion
  ended('Ended', 'Session completed'),

  /// Session ended due to error or unexpected disconnection
  /// This state is trying to indicate abnormal termination
  terminated('Terminated', 'Session ended unexpectedly');

  /// Constructor for GameSessionState enum with display values
  const GameSessionState(this.name, this.description);

  /// Short name for the session state
  final String name;

  /// Descriptive text for UI display and status messages
  final String description;
}

/// Permission state enumeration for handling device permissions
/// This enum is attempting to track permission request outcomes
enum PermissionState {
  /// Permission status is unknown or not yet requested
  /// This state is meant to represent initial app state
  unknown('Unknown', 'Permission status unknown'),

  /// Permission has been granted by the user
  /// This state is trying to indicate successful permission approval
  granted('Granted', 'Permission granted'),

  /// Permission was denied by the user
  /// This state is meant to indicate user declined permission
  denied('Denied', 'Permission denied'),

  /// Permission was permanently denied (requires app settings change)
  /// This state is trying to indicate need for manual settings adjustment
  permanentlyDenied('Permanently Denied', 'Permission permanently denied'),

  /// Permission is restricted by device policy or parental controls
  /// This state is meant to indicate system-level restrictions
  restricted('Restricted', 'Permission restricted by system');

  /// Constructor for PermissionState enum with display values
  const PermissionState(this.name, this.description);

  /// Short name for the permission state
  final String name;

  /// Descriptive text for UI display and error handling
  final String description;
}

/// Message type enumeration for P2P communication protocol
/// This enum is attempting to define the types of messages sent between devices
enum MessageType {
  /// Rating change message - when a user changes their consent rating
  /// This message type is meant to synchronize traffic light states
  ratingChange('rating_change', 'Consent rating updated'),

  /// Session control message - start, pause, end session commands
  /// This message type is trying to coordinate session lifecycle
  sessionControl('session_control', 'Session control command'),

  /// Player join message - when a new player connects to the session
  /// This message type is meant to notify all participants of new members
  playerJoin('player_join', 'Player joined session'),

  /// Player leave message - when a player disconnects from the session
  /// This message type is trying to notify all participants of departures
  playerLeave('player_leave', 'Player left session'),

  /// Heartbeat message - periodic connectivity check
  /// This message type is meant to maintain connection health
  heartbeat('heartbeat', 'Connection heartbeat'),

  /// Feedback message - post-session questionnaire responses
  /// This message type is trying to collect session feedback
  feedback('feedback', 'Session feedback submitted');

  /// Constructor for MessageType enum with protocol values
  const MessageType(this.protocol, this.description);

  /// Protocol identifier for message serialization
  final String protocol;

  /// Descriptive text for debugging and logging
  final String description;

  /// Helper method to get message type from protocol string
  /// This method is attempting to provide safe deserialization
  static MessageType? fromProtocol(String protocol) {
    for (MessageType type in MessageType.values) {
      if (type.protocol == protocol) {
        return type;
      }
    }
    return null;
  }
}
