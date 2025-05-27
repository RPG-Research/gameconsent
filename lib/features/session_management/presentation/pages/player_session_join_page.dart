// lib/features/session_management/presentation/pages/player_session_join_page.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Player session discovery and joining screen
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

// Core imports for constants and enums
import 'package:gameconsentbasic/core/constants/app_constants.dart';
import 'package:gameconsentbasic/core/enums/app_enums.dart';

/// Model class for discovered GameConsent sessions
/// This class is attempting to represent available sessions for joining
class DiscoveredSession {
  /// Constructor for discovered session data
  /// This constructor is trying to encapsulate session discovery information
  const DiscoveredSession({
    required this.sessionId,
    required this.sessionName,
    required this.hostName,
    required this.isPasswordProtected,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.signalStrength,
    required this.lastSeen,
  });

  /// Unique identifier for this session
  final String sessionId;

  /// Display name of the session
  final String sessionName;

  /// Name/identifier of the hosting device
  final String hostName;

  /// Whether this session requires a password to join
  final bool isPasswordProtected;

  /// Number of players currently connected
  final int currentPlayers;

  /// Maximum number of players allowed
  final int maxPlayers;

  /// Bluetooth signal strength (0-100)
  final int signalStrength;

  /// When this session was last seen during scanning
  final DateTime lastSeen;

  /// Whether this session is full
  bool get isFull => currentPlayers >= maxPlayers;

  /// Whether this session was recently seen (within last 30 seconds)
  bool get isActive => DateTime.now().difference(lastSeen).inSeconds < 30;
}

/// Player Session Join Page
/// This page is attempting to guide players through discovering and joining
/// GameConsent sessions hosted by Game Masters
class PlayerSessionJoinPage extends StatefulWidget {
  const PlayerSessionJoinPage({super.key});

  @override
  State<PlayerSessionJoinPage> createState() => _PlayerSessionJoinPageState();
}

class _PlayerSessionJoinPageState extends State<PlayerSessionJoinPage>
    with TickerProviderStateMixin {
  /// Logger instance for debugging session discovery and joining
  /// This logger is attempting to track player interaction flows
  final Logger _logger = Logger();

  /// Animation controller for UI transitions and scanning feedback
  /// This controller is trying to provide smooth visual interactions
  late AnimationController _animationController;

  /// Animation controller specifically for scanning pulse effect
  /// This controller is attempting to show active scanning state
  late AnimationController _scanAnimationController;

  /// Fade animation for page transitions
  /// This animation is meant to provide smooth state changes
  late Animation<double> _fadeAnimation;

  /// Pulse animation for scanning indicator
  /// This animation is trying to show active Bluetooth scanning
  late Animation<double> _pulseAnimation;

  /// Current Bluetooth connection state
  /// This state is attempting to track scanning and connection progress
  BluetoothConnectionState _connectionState = BluetoothConnectionState.enabled;

  /// Current game session state for this player
  /// This state is meant to track the player's session participation
  GameSessionState _sessionState = GameSessionState.idle;

  /// List of discovered GameConsent sessions
  /// This list is attempting to show available sessions to the player
  final List<DiscoveredSession> _discoveredSessions = [];

  /// Currently selected session for joining
  /// This session is meant to be the player's choice for joining
  DiscoveredSession? _selectedSession;

  /// Whether Bluetooth scanning is currently active
  /// This flag is trying to control scanning state and UI feedback
  bool _isScanning = false;

  /// Whether a session join attempt is in progress
  /// This flag is meant to prevent multiple simultaneous join attempts
  bool _isJoining = false;

  /// Text controller for password input when joining protected sessions
  /// This controller is attempting to handle session password entry
  final TextEditingController _passwordController = TextEditingController();

  /// Whether password input should be obscured
  /// This flag is trying to provide secure password entry
  bool _obscurePassword = true;

  /// Current consent rating for active session participation
  /// This rating is meant to track the player's comfort level
  ConsentRating _currentRating = ConsentRating.green;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for smooth UI transitions
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Set up animations for visual feedback
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entrance animation
    _animationController.forward();

    // Automatically start scanning for sessions
    _startScanning();

    // Log player session join page initialization
    if (AppConstants.isDebugMode) {
      _logger.i('👤 Player Session Join page initialized');
    }
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _animationController.dispose();
    _scanAnimationController.dispose();
    _passwordController.dispose();

    // Stop scanning if still active
    if (_isScanning) {
      _stopScanning();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with player context and controls
      appBar: AppBar(
        title: const Text('Join GameConsent Session'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Refresh/scan button
          IconButton(
            icon: AnimatedBuilder(
              animation: _scanAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isScanning ? _pulseAnimation.value : 1.0,
                  child: Icon(
                    _isScanning ? Icons.bluetooth_searching : Icons.refresh,
                  ),
                );
              },
            ),
            onPressed: _isScanning ? _stopScanning : _startScanning,
            tooltip: _isScanning ? 'Stop Scanning' : 'Scan for Sessions',
          ),

          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Join Session Help',
          ),
        ],
      ),

      // Main content based on current session state
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildMainContent(context),
          );
        },
      ),
    );
  }

  /// Build main content based on current session state
  /// This method is attempting to show appropriate UI for each stage
  Widget _buildMainContent(BuildContext context) {
    switch (_sessionState) {
      case GameSessionState.idle:
        return _buildSessionDiscoveryScreen(context);
      case GameSessionState.joining:
        return _buildJoiningProgressScreen(context);
      case GameSessionState.active:
        return _buildActiveSessionScreen(context);
      default:
        return _buildSessionDiscoveryScreen(context);
    }
  }

  /// Build the session discovery screen with available sessions
  /// This screen is attempting to show found GameConsent sessions to join
  Widget _buildSessionDiscoveryScreen(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header section with player role confirmation
          _buildHeaderSection(context),

          // Connection status and scanning controls
          _buildConnectionStatusSection(context),

          // Available sessions list
          Expanded(child: _buildAvailableSessionsList(context)),
        ],
      ),
    );
  }

  /// Build header section with player role confirmation
  /// This section is attempting to confirm the user's role and explain the process
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConstants.spacingLarge),
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2196F3,
                  ).withOpacity(0.2), // Blue for player
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF2196F3),
                  size: 25,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player Mode',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Find and join a GameConsent session',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'Look for GameConsent sessions hosted by Game Masters in your area. '
            'Your consent ratings will be sent anonymously to help manage the group\'s comfort level.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build connection status section with scanning controls
  /// This section is attempting to show Bluetooth status and scanning progress
  Widget _buildConnectionStatusSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getConnectionStatusColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Status indicator
          AnimatedBuilder(
            animation: _scanAnimationController,
            builder: (context, child) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getConnectionStatusColor().withOpacity(
                    _isScanning ? _pulseAnimation.value * 0.3 : 0.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getConnectionStatusIcon(),
                  color: _getConnectionStatusColor(),
                  size: 20,
                ),
              );
            },
          ),

          const SizedBox(width: AppConstants.spacingMedium),

          // Status text and session count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getConnectionStatusText(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getConnectionStatusColor(),
                  ),
                ),
                Text(
                  _isScanning
                      ? 'Scanning for sessions...'
                      : '${_discoveredSessions.length} sessions found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Scan control button
          TextButton.icon(
            onPressed: _isScanning ? _stopScanning : _startScanning,
            icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow, size: 16),
            label: Text(_isScanning ? 'Stop' : 'Scan'),
            style: TextButton.styleFrom(
              foregroundColor: _getConnectionStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build available sessions list
  /// This section is attempting to display discovered sessions for joining
  Widget _buildAvailableSessionsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text(
                'Available Sessions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_discoveredSessions.isNotEmpty)
                Text(
                  '${_discoveredSessions.length} found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Sessions list or empty state
          Expanded(
            child: _discoveredSessions.isEmpty
                ? _buildEmptySessionsList(context)
                : _buildSessionsList(context),
          ),
        ],
      ),
    );
  }

  /// Build empty sessions list state
  /// This widget is attempting to guide users when no sessions are found
  Widget _buildEmptySessionsList(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            _isScanning
                ? 'Searching for GameConsent sessions...'
                : 'No GameConsent sessions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            _isScanning
                ? 'Make sure you\'re near a Game Master who has started a session.'
                : 'Tap the scan button to search for nearby sessions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isScanning) ...[
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Start Scanning'),
            ),
          ],
        ],
      ),
    );
  }

  /// Build sessions list with discovered sessions
  /// This widget is attempting to display available sessions for selection
  Widget _buildSessionsList(BuildContext context) {
    return ListView.builder(
      itemCount: _discoveredSessions.length,
      itemBuilder: (context, index) {
        final session = _discoveredSessions[index];
        return _buildSessionListItem(context, session);
      },
    );
  }

  /// Build individual session list item
  /// This method is attempting to display session information attractively
  Widget _buildSessionListItem(
    BuildContext context,
    DiscoveredSession session,
  ) {
    final bool isSelected = _selectedSession?.sessionId == session.sessionId;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: () => _selectSession(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session header with name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.sessionName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                        Text(
                          'Hosted by ${session.hostName}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Session status indicators
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Password protection indicator
                      if (session.isPasswordProtected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Protected',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Full indicator
                      if (session.isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Full',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingSmall),

              // Session details row
              Row(
                children: [
                  // Player count
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.currentPlayers}/${session.maxPlayers} players',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(width: AppConstants.spacingMedium),

                  // Signal strength
                  Icon(
                    _getSignalStrengthIcon(session.signalStrength),
                    size: 16,
                    color: _getSignalStrengthColor(session.signalStrength),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getSignalStrengthText(session.signalStrength),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getSignalStrengthColor(session.signalStrength),
                    ),
                  ),

                  const Spacer(),

                  // Last seen indicator
                  if (session.isActive)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),

              // Join button for selected session
              if (isSelected && !session.isFull) ...[
                const SizedBox(height: AppConstants.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isJoining ? null : () => _joinSession(session),
                    child: _isJoining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            session.isPasswordProtected
                                ? 'Join with Password'
                                : 'Join Session',
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build joining progress screen
  /// This screen is attempting to show progress while connecting to a session
  Widget _buildJoiningProgressScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading indicator
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            Text(
              'Joining GameConsent Session...',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            if (_selectedSession != null) ...[
              Text(
                '"${_selectedSession!.sessionName}"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
            ],

            Text(
              'Please wait while we connect you to the session.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build active session screen with traffic light interface
  /// This screen is attempting to show the consent management interface for players
  Widget _buildActiveSessionScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            // Session header
            _buildActiveSessionHeader(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Traffic light consent interface
            Expanded(child: _buildPlayerTrafficLightInterface(context)),

            const SizedBox(height: AppConstants.spacingLarge),

            // Session controls for player
            _buildPlayerSessionControls(context),
          ],
        ),
      ),
    );
  }

  /// Build active session header for player
  /// This method is attempting to show current session status to the player
  Widget _buildActiveSessionHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Connected to Session',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          if (_selectedSession != null) ...[
            Text(
              _selectedSession!.sessionName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              'Hosted by ${_selectedSession!.hostName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build player traffic light consent interface
  /// This method is attempting to create the consent rating interface for players
  Widget _buildPlayerTrafficLightInterface(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your Consent Level',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        Text(
          'Tap a rating to let the Game Master know your comfort level',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacingXLarge),

        // Traffic light interface
        Container(
          width: 200,
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Green light
              _buildPlayerTrafficLightButton(
                context,
                ConsentRating.green,
                _currentRating == ConsentRating.green,
              ),

              // Yellow light
              _buildPlayerTrafficLightButton(
                context,
                ConsentRating.yellow,
                _currentRating == ConsentRating.yellow,
              ),

              // Red light
              _buildPlayerTrafficLightButton(
                context,
                ConsentRating.red,
                _currentRating == ConsentRating.red,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacingLarge),

        // Current rating description
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: Color(_currentRating.colorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(_currentRating.colorValue).withOpacity(0.3),
            ),
          ),
          child: Text(
            _currentRating.description,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Color(_currentRating.colorValue),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build individual traffic light button for player
  /// This method is attempting to create interactive consent rating buttons
  Widget _buildPlayerTrafficLightButton(
    BuildContext context,
    ConsentRating rating,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => _changeConsentRating(rating),
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        width: AppConstants.d20ButtonSize,
        height: AppConstants.d20ButtonSize,
        decoration: BoxDecoration(
          color: isActive
              ? Color(rating.colorValue)
              : Color(rating.colorValue).withOpacity(0.3),
          shape:
              BoxShape.circle, // Simplified for now - will be d20 shape later
          border: Border.all(
            color: Color(rating.colorValue),
            width: AppConstants.d20ButtonBorderWidth,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Color(rating.colorValue).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            rating.name.toUpperCase(),
            style: TextStyle(
              color: isActive ? Colors.white : Color(rating.colorValue),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Build session controls for player
  /// This method is attempting to provide player-specific session controls
  Widget _buildPlayerSessionControls(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showLeaveSessionDialog,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingMedium,
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        child: Text(
          'Leave Session',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  /// Start Bluetooth scanning for GameConsent sessions
  /// This method is attempting to discover available sessions
  Future<void> _startScanning() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _connectionState = BluetoothConnectionState.scanning;
      _discoveredSessions.clear();
    });

    // Start scanning animation
    _scanAnimationController.repeat();

    if (AppConstants.isDebugMode) {
      _logger.i('🔍 Starting Bluetooth scan for GameConsent sessions');
    }

    try {
      // TODO: Implement actual Bluetooth scanning
      // This will be replaced with real Bluetooth discovery functionality

      // Simulate scanning with mock sessions for development
      await _simulateSessionDiscovery();
    } catch (e) {
      _logger.e('❌ Error during session scanning: $e');
      _showErrorMessage(
        'Scanning failed. Please check your Bluetooth settings and try again.',
      );
    }
  }

  /// Stop Bluetooth scanning
  /// This method is attempting to halt session discovery
  void _stopScanning() {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
      _connectionState = BluetoothConnectionState.enabled;
    });

    // Stop scanning animation
    _scanAnimationController.reset();

    if (AppConstants.isDebugMode) {
      _logger.i('⏹️ Stopped Bluetooth scanning');
    }

    // TODO: Stop actual Bluetooth scanning
  }

  /// Simulate session discovery for development purposes
  /// This method is attempting to provide mock data during development
  Future<void> _simulateSessionDiscovery() async {
    // Add mock sessions gradually to simulate real discovery
    await Future.delayed(const Duration(seconds: 1));

    if (_isScanning) {
      setState(() {
        _discoveredSessions.add(
          DiscoveredSession(
            sessionId: 'session-1',
            sessionName: 'GameConsent Session Alpha',
            hostName: 'GM-Device-001',
            isPasswordProtected: false,
            currentPlayers: 2,
            maxPlayers: 6,
            signalStrength: 85,
            lastSeen: DateTime.now(),
          ),
        );
      });
    }

    await Future.delayed(const Duration(seconds: 2));

    if (_isScanning) {
      setState(() {
        _discoveredSessions.add(
          DiscoveredSession(
            sessionId: 'session-2',
            sessionName: 'Private Gaming Group',
            hostName: 'GM-Device-002',
            isPasswordProtected: true,
            currentPlayers: 1,
            maxPlayers: 4,
            signalStrength: 65,
            lastSeen: DateTime.now(),
          ),
        );
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    if (_isScanning) {
      setState(() {
        _discoveredSessions.add(
          DiscoveredSession(
            sessionId: 'session-3',
            sessionName: 'Weekly D&D Campaign',
            hostName: 'GM-Device-003',
            isPasswordProtected: false,
            currentPlayers: 8,
            maxPlayers: 8,
            signalStrength: 45,
            lastSeen: DateTime.now(),
          ),
        );
      });
    }

    // Auto-stop scanning after finding sessions
    await Future.delayed(const Duration(seconds: 3));
    if (_isScanning && _discoveredSessions.isNotEmpty) {
      _stopScanning();
    }
  }

  /// Select a session for joining
  /// This method is attempting to handle session selection
  void _selectSession(DiscoveredSession session) {
    if (session.isFull) {
      _showErrorMessage('This session is full and cannot accept more players.');
      return;
    }

    setState(() {
      _selectedSession = session;
    });

    if (AppConstants.isDebugMode) {
      _logger.i('📱 Selected session: ${session.sessionName}');
    }

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  /// Join the selected GameConsent session
  /// This method is attempting to handle the session joining process
  Future<void> _joinSession(DiscoveredSession session) async {
    if (session.isPasswordProtected) {
      // Show password dialog first
      final String? password = await _showPasswordDialog(session);
      if (password == null || password.isEmpty) {
        return; // User cancelled or entered empty password
      }
    }

    setState(() {
      _isJoining = true;
      _sessionState = GameSessionState.joining;
    });

    if (AppConstants.isDebugMode) {
      _logger.i('🔗 Attempting to join session: ${session.sessionName}');
    }

    try {
      // TODO: Implement actual session joining via Bluetooth P2P
      // This will include password verification if required

      // Simulate joining process
      await Future.delayed(const Duration(seconds: 3));

      // Success - transition to active session
      setState(() {
        _sessionState = GameSessionState.active;
        _isJoining = false;
        _currentRating = ConsentRating.green; // Start at green
      });

      _showSuccessMessage('Successfully joined "${session.sessionName}"!');
    } catch (e) {
      _logger.e('❌ Error joining session: $e');

      setState(() {
        _sessionState = GameSessionState.idle;
        _isJoining = false;
      });

      _showErrorMessage('Failed to join session. Please try again.');
    }
  }

  /// Show password input dialog for protected sessions
  /// This method is attempting to handle password-protected session access
  Future<String?> _showPasswordDialog(DiscoveredSession session) async {
    _passwordController.clear();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter Session Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session "${session.sessionName}" is password protected.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter session password',
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: _obscurePassword,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = _passwordController.text.trim();
              if (password.isNotEmpty) {
                Navigator.of(context).pop(password);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  /// Change player's consent rating
  /// This method is attempting to handle consent rating changes
  void _changeConsentRating(ConsentRating rating) {
    if (_currentRating == rating) return;

    setState(() {
      _currentRating = rating;
    });

    if (AppConstants.isDebugMode) {
      _logger.i('🚦 Player changed consent rating to: ${rating.name}');
    }

    // TODO: Send rating change to Game Master via P2P
    // This will broadcast the rating change to all session participants

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    _showSuccessMessage(
      'Consent level changed to ${rating.name.toUpperCase()}',
    );
  }

  /// Show dialog to confirm leaving the session
  /// This method is attempting to prevent accidental session departure
  void _showLeaveSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Session'),
        content: const Text(
          'Are you sure you want to leave this GameConsent session? '
          'You will need to rejoin to continue participating.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _leaveSession();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave Session'),
          ),
        ],
      ),
    );
  }

  /// Leave the current GameConsent session
  /// This method is attempting to properly disconnect from the session
  void _leaveSession() {
    if (AppConstants.isDebugMode) {
      _logger.i('👋 Player leaving session: ${_selectedSession?.sessionName}');
    }

    // TODO: Notify Game Master of player departure via P2P

    setState(() {
      _sessionState = GameSessionState.idle;
      _selectedSession = null;
      _currentRating = ConsentRating.green;
    });

    _showSuccessMessage('Left the GameConsent session');

    // Return to session discovery
    _startScanning();
  }

  /// Show help dialog for joining sessions
  /// This method is attempting to provide user guidance
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Joining Sessions Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How to Join a GameConsent Session:\n\n'
                '1. Ensure Bluetooth is enabled on your device\n\n'
                '2. Tap "Scan" to search for nearby sessions\n\n'
                '3. Select a session from the list\n\n'
                '4. Enter password if the session is protected\n\n'
                '5. Use the traffic light to signal your comfort level\n\n'
                '• GREEN = Comfortable, proceed\n'
                '• YELLOW = Cautious, slow down\n'
                '• RED = Uncomfortable, stop',
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'Need more help? Visit ${AppConstants.supportUrl}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  /// Get connection status color for UI theming
  /// This method is attempting to provide visual status feedback
  Color _getConnectionStatusColor() {
    switch (_connectionState) {
      case BluetoothConnectionState.enabled:
      case BluetoothConnectionState.sessionsFound:
        return Colors.green;
      case BluetoothConnectionState.scanning:
        return Colors.blue;
      case BluetoothConnectionState.connecting:
        return Colors.orange;
      case BluetoothConnectionState.error:
      case BluetoothConnectionState.unavailable:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get connection status icon for UI display
  /// This method is attempting to provide visual status indicators
  IconData _getConnectionStatusIcon() {
    switch (_connectionState) {
      case BluetoothConnectionState.enabled:
        return Icons.bluetooth;
      case BluetoothConnectionState.scanning:
        return Icons.bluetooth_searching;
      case BluetoothConnectionState.sessionsFound:
        return Icons.bluetooth_connected;
      case BluetoothConnectionState.connecting:
        return Icons.bluetooth_disabled;
      case BluetoothConnectionState.error:
        return Icons.error;
      default:
        return Icons.bluetooth_disabled;
    }
  }

  /// Get connection status text for UI display
  /// This method is attempting to provide clear status messages
  String _getConnectionStatusText() {
    switch (_connectionState) {
      case BluetoothConnectionState.enabled:
        return 'Bluetooth Ready';
      case BluetoothConnectionState.scanning:
        return 'Scanning...';
      case BluetoothConnectionState.sessionsFound:
        return 'Sessions Found';
      case BluetoothConnectionState.connecting:
        return 'Connecting...';
      case BluetoothConnectionState.error:
        return 'Connection Error';
      default:
        return 'Bluetooth Unavailable';
    }
  }

  /// Get signal strength icon based on strength value
  /// This method is attempting to provide visual signal indicators
  IconData _getSignalStrengthIcon(int strength) {
    if (strength >= 80) return Icons.network_wifi;
    if (strength >= 60) return Icons.network_wifi;
    if (strength >= 40) return Icons.network_wifi;
    if (strength >= 20) return Icons.network_wifi_1_bar;
    return Icons.network_wifi_1_bar;
  }

  /// Get signal strength color based on strength value
  /// This method is attempting to provide color-coded signal quality
  Color _getSignalStrengthColor(int strength) {
    if (strength >= 70) return Colors.green;
    if (strength >= 40) return Colors.orange;
    return Colors.red;
  }

  /// Get signal strength text based on strength value
  /// This method is attempting to provide readable signal quality
  String _getSignalStrengthText(int strength) {
    if (strength >= 80) return 'Excellent';
    if (strength >= 60) return 'Good';
    if (strength >= 40) return 'Fair';
    if (strength >= 20) return 'Poor';
    return 'Very Poor';
  }

  /// Show success message to user
  /// This method is attempting to provide positive feedback
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error message to user
  /// This method is attempting to provide error feedback
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
