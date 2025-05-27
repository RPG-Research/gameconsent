// lib/features/session_management/presentation/pages/gm_session_setup_page.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Game Master session setup and hosting screen
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

// Core imports for constants and enums
import 'package:gameconsentbasic/core/constants/app_constants.dart';
import 'package:gameconsentbasic/core/enums/app_enums.dart';

/// Game Master Session Setup Page
/// This page is attempting to guide Game Masters through creating and hosting
/// a GameConsent session with optional password protection
class GMSessionSetupPage extends StatefulWidget {
  const GMSessionSetupPage({super.key});

  @override
  State<GMSessionSetupPage> createState() => _GMSessionSetupPageState();
}

class _GMSessionSetupPageState extends State<GMSessionSetupPage>
    with TickerProviderStateMixin {
  /// Logger instance for debugging session setup flow
  /// This logger is attempting to track session creation and hosting events
  final Logger _logger = Logger();

  /// UUID generator for creating unique session identifiers
  /// This generator is trying to ensure each session has a unique ID
  final Uuid _uuid = const Uuid();

  /// Animation controller for page transitions and feedback
  /// This controller is attempting to provide smooth visual interactions
  late AnimationController _animationController;

  /// Form key for session setup validation
  /// This key is trying to ensure proper form validation before session creation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Text editing controllers for form inputs
  /// These controllers are attempting to manage user input for session configuration
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// Current game session state
  /// This state is meant to track the session creation and hosting progress
  GameSessionState _sessionState = GameSessionState.idle;

  /// Whether password protection is enabled for this session
  /// This flag is trying to control password-related UI and validation
  bool _isPasswordProtected = false;

  /// Whether password fields should be obscured
  /// These flags are attempting to provide secure password input
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Whether the session is currently being created/started
  /// This flag is meant to prevent multiple simultaneous session creation attempts
  bool _isCreatingSession = false;

  /// Generated session ID for this GameConsent session
  /// This ID is attempting to uniquely identify the session for P2P connections
  String? _sessionId;

  /// Number of players currently connected to this session
  /// This counter is trying to track session participation
  final int _connectedPlayers = 0;

  /// Maximum number of players allowed in this session
  /// This limit is attempting to maintain good P2P performance
  final int _maxPlayers = AppConstants.maxPlayersPerSession;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    // Pre-populate session name with default value
    // This default is trying to provide a reasonable starting point
    _sessionNameController.text =
        '${AppConstants.defaultSessionPrefix} ${DateTime.now().day}';

    // Start entrance animation
    _animationController.forward();

    // Log GM session setup initialization
    if (AppConstants.isDebugMode) {
      _logger.i('🎮 GM Session Setup page initialized');
    }
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _animationController.dispose();
    _sessionNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with session setup context
      appBar: AppBar(
        title: const Text('Create GameConsent Session'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Help button for session setup guidance
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Session Setup Help',
          ),
        ],
      ),

      // Main content based on current session state
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return _buildMainContent(context);
        },
      ),

      // Bottom action bar with create/start session controls
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  /// Build main content based on current session state
  /// This method is attempting to show appropriate UI for each stage of setup
  Widget _buildMainContent(BuildContext context) {
    switch (_sessionState) {
      case GameSessionState.idle:
        return _buildSessionConfigurationForm(context);
      case GameSessionState.creating:
        return _buildSessionCreationProgress(context);
      case GameSessionState.waitingForPlayers:
        return _buildWaitingForPlayersScreen(context);
      case GameSessionState.active:
        return _buildActiveSessionScreen(context);
      default:
        return _buildSessionConfigurationForm(context);
    }
  }

  /// Build the session configuration form
  /// This form is attempting to collect session details from the Game Master
  Widget _buildSessionConfigurationForm(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with GM role confirmation
              _buildHeaderSection(context),

              const SizedBox(height: AppConstants.spacingXLarge),

              // Session name input section
              _buildSessionNameSection(context),

              const SizedBox(height: AppConstants.spacingLarge),

              // Password protection section
              _buildPasswordProtectionSection(context),

              const SizedBox(height: AppConstants.spacingLarge),

              // Session configuration summary
              _buildSessionSummarySection(context),

              const SizedBox(height: AppConstants.spacingXLarge),

              // Important notes for Game Masters
              _buildImportantNotesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section with GM role confirmation
  /// This section is attempting to confirm the user's role and explain the next steps
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Master Setup',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Configure and host your GameConsent session',
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
            'As the Game Master, you will host this session and receive anonymous consent ratings from all players in real-time. Players will see the traffic light status but you won\'t know who sent each rating.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build session name input section
  /// This section is attempting to collect and validate the session name
  Widget _buildSessionNameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Name',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          'Choose a name that players will recognize when joining your session',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        TextFormField(
          controller: _sessionNameController,
          decoration: InputDecoration(
            labelText: 'Session Name',
            hintText: 'e.g., ${AppConstants.defaultSessionPrefix} 1',
            prefixIcon: const Icon(Icons.groups),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText:
                '${_sessionNameController.text.length}/${AppConstants.sessionNameMaxLength}',
          ),
          maxLength: AppConstants.sessionNameMaxLength,
          textInputAction: TextInputAction.next,
          validator: _validateSessionName,
          onChanged: (value) {
            setState(() {}); // Trigger rebuild to update counter
          },
        ),
      ],
    );
  }

  /// Build password protection section
  /// This section is attempting to handle optional session password configuration
  Widget _buildPasswordProtectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password protection toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMedium),
            child: Row(
              children: [
                Icon(
                  _isPasswordProtected ? Icons.lock : Icons.lock_open,
                  color: _isPasswordProtected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Protection',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Require a password for players to join this session',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isPasswordProtected,
                  onChanged: (value) {
                    setState(() {
                      _isPasswordProtected = value;
                      if (!value) {
                        // Clear password fields when disabling protection
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        // Password input fields (shown only when protection is enabled)
        if (_isPasswordProtected) ...[
          const SizedBox(height: AppConstants.spacingMedium),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Session Password',
              hintText: 'Enter password for your session',
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
              counterText:
                  '${_passwordController.text.length}/${AppConstants.passwordMaxLength}',
            ),
            obscureText: _obscurePassword,
            maxLength: AppConstants.passwordMaxLength,
            textInputAction: TextInputAction.next,
            validator: _isPasswordProtected ? _validatePassword : null,
            onChanged: (value) {
              setState(() {}); // Trigger rebuild to update counter
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter the same password',
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            maxLength: AppConstants.passwordMaxLength,
            textInputAction: TextInputAction.done,
            validator: _isPasswordProtected ? _validateConfirmPassword : null,
            onChanged: (value) {
              setState(() {}); // Trigger rebuild for validation feedback
            },
          ),
        ],
      ],
    );
  }

  /// Build session configuration summary
  /// This section is attempting to show the user their current session settings
  Widget _buildSessionSummarySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Session name summary
          _buildSummaryItem(
            context,
            Icons.groups,
            'Session Name',
            _sessionNameController.text.isEmpty
                ? 'Not set'
                : _sessionNameController.text,
          ),

          // Password protection summary
          _buildSummaryItem(
            context,
            _isPasswordProtected ? Icons.lock : Icons.lock_open,
            'Password Protection',
            _isPasswordProtected ? 'Enabled' : 'Disabled',
          ),

          // Maximum players summary
          _buildSummaryItem(
            context,
            Icons.people,
            'Maximum Players',
            '$_maxPlayers players',
          ),
        ],
      ),
    );
  }

  /// Build individual summary item
  /// This method is attempting to display configuration details consistently
  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppConstants.spacingSmall),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build important notes section for Game Masters
  /// This section is attempting to provide helpful guidance and tips
  Widget _buildImportantNotesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                'Important Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // List of important notes
          ..._getImportantNotes().map((note) => _buildNoteItem(context, note)),
        ],
      ),
    );
  }

  /// Build individual note item
  /// This method is attempting to display important information clearly
  Widget _buildNoteItem(BuildContext context, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(note, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  /// Build session creation progress screen
  /// This screen is attempting to show progress while the session is being created
  Widget _buildSessionCreationProgress(BuildContext context) {
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
              'Creating GameConsent Session...',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            Text(
              'Please wait while we set up your session for Bluetooth discovery.',
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

  /// Build waiting for players screen
  /// This screen is attempting to show session status while waiting for players to join
  Widget _buildWaitingForPlayersScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            // Session status header
            _buildSessionStatusHeader(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Connected players section
            Expanded(child: _buildConnectedPlayersSection(context)),

            const SizedBox(height: AppConstants.spacingLarge),

            // Session controls
            _buildSessionControls(context),
          ],
        ),
      ),
    );
  }

  /// Build active session screen with traffic light interface
  /// This screen is attempting to show the active consent management interface
  Widget _buildActiveSessionScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          children: [
            // Session header with player count
            _buildActiveSessionHeader(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Traffic light consent interface
            Expanded(child: _buildTrafficLightInterface(context)),

            const SizedBox(height: AppConstants.spacingLarge),

            // Session management controls
            _buildActiveSessionControls(context),
          ],
        ),
      ),
    );
  }

  /// Build session status header
  /// This method is attempting to display current session information
  Widget _buildSessionStatusHeader(BuildContext context) {
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
            'Session Active',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            _sessionNameController.text,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (_isPasswordProtected)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: AppConstants.spacingXSmall),
                  Text(
                    'Password Protected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build connected players section
  /// This method is attempting to show current session participants
  Widget _buildConnectedPlayersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connected Players',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // Player count indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$_connectedPlayers',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'of $_maxPlayers players',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Instructions for players
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Players can now scan for and join your session "${_sessionNameController.text}".\n\n'
            'Once at least one player joins, you can start the consent monitoring session.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build active session header
  /// This method is attempting to show session status during active monitoring
  Widget _buildActiveSessionHeader(BuildContext context) {
    return _buildSessionStatusHeader(context);
  }

  /// Build traffic light consent interface
  /// This method is attempting to create the core consent monitoring UI
  Widget _buildTrafficLightInterface(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Current Consent Level',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacingXLarge),

        // TODO: This will be replaced with actual traffic light interface
        // For now, showing a placeholder
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
              // Green light (default active)
              _buildTrafficLightButton(context, ConsentRating.green, true),

              // Yellow light
              _buildTrafficLightButton(context, ConsentRating.yellow, false),

              // Red light
              _buildTrafficLightButton(context, ConsentRating.red, false),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacingLarge),

        Text(
          'All participants start at GREEN. Any participant can change the group consent level.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build individual traffic light button
  /// This method is attempting to create d20-shaped consent rating buttons
  Widget _buildTrafficLightButton(
    BuildContext context,
    ConsentRating rating,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => _handleConsentRatingChange(rating),
      child: Container(
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

  /// Build session controls for waiting state
  /// This method is attempting to provide session management options
  Widget _buildSessionControls(BuildContext context) {
    return Column(
      children: [
        // Start session button (enabled when players are connected)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _connectedPlayers > 0 ? _startActiveSession : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMedium,
              ),
            ),
            child: Text(
              _connectedPlayers > 0
                  ? 'Start Consent Monitoring'
                  : 'Waiting for Players...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // End session button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _showEndSessionDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMedium,
              ),
            ),
            child: const Text(
              'End Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Build active session controls
  /// This method is attempting to provide controls during active monitoring
  Widget _buildActiveSessionControls(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showEndSessionDialog,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingMedium,
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        child: Text(
          'End Session',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  /// Build bottom action bar based on current state
  /// This method is attempting to provide appropriate actions for each session state
  Widget _buildBottomActionBar(BuildContext context) {
    // Only show bottom bar in idle state (configuration form)
    if (_sessionState != GameSessionState.idle) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreatingSession ? null : _createSession,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMedium,
              ),
            ),
            child: _isCreatingSession
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Session',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  /// Validate session name input
  /// This method is attempting to ensure session names meet requirements
  String? _validateSessionName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Session name is required';
    }

    if (value.trim().length < AppConstants.sessionNameMinLength) {
      return 'Session name must be at least ${AppConstants.sessionNameMinLength} characters';
    }

    if (value.length > AppConstants.sessionNameMaxLength) {
      return 'Session name cannot exceed ${AppConstants.sessionNameMaxLength} characters';
    }

    return null;
  }

  /// Validate password input
  /// This method is attempting to ensure passwords meet security requirements
  String? _validatePassword(String? value) {
    if (!_isPasswordProtected) return null;

    if (value == null || value.isEmpty) {
      return 'Password is required when protection is enabled';
    }

    if (value.length < AppConstants.passwordMinLength) {
      return 'Password must be at least ${AppConstants.passwordMinLength} characters';
    }

    if (value.length > AppConstants.passwordMaxLength) {
      return 'Password cannot exceed ${AppConstants.passwordMaxLength} characters';
    }

    return null;
  }

  /// Validate password confirmation
  /// This method is attempting to ensure password confirmation matches
  String? _validateConfirmPassword(String? value) {
    if (!_isPasswordProtected) return null;

    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Create and start hosting the GameConsent session
  /// This method is attempting to initialize the Bluetooth P2P session
  Future<void> _createSession() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingSession = true;
      _sessionState = GameSessionState.creating;
    });

    try {
      // Generate unique session ID
      _sessionId = _uuid.v4();

      // Log session creation attempt
      if (AppConstants.isDebugMode) {
        _logger.i(
          '🎮 Creating GameConsent session: ${_sessionNameController.text}',
        );
        _logger.d('Session ID: $_sessionId');
        _logger.d('Password protected: $_isPasswordProtected');
      }

      // TODO: Initialize Bluetooth advertising/hosting
      // This will be implemented with actual Bluetooth functionality

      // Simulate session creation delay
      await Future.delayed(const Duration(seconds: 2));

      // Update state to waiting for players
      setState(() {
        _sessionState = GameSessionState.waitingForPlayers;
        _isCreatingSession = false;
      });

      // Show success message
      _showSuccessMessage(
        'Session "${_sessionNameController.text}" created successfully!',
      );
    } catch (e) {
      _logger.e('❌ Error creating session: $e');

      setState(() {
        _sessionState = GameSessionState.idle;
        _isCreatingSession = false;
      });

      _showErrorDialog(
        'Session Creation Failed',
        'Unable to create the GameConsent session. Please check your Bluetooth settings and try again.',
      );
    }
  }

  /// Start active consent monitoring session
  /// This method is attempting to transition from waiting to active monitoring
  void _startActiveSession() {
    if (_connectedPlayers == 0) return;

    setState(() {
      _sessionState = GameSessionState.active;
    });

    if (AppConstants.isDebugMode) {
      _logger.i(
        '🚦 Starting active consent monitoring with $_connectedPlayers players',
      );
    }

    _showSuccessMessage('Consent monitoring is now active!');
  }

  /// Handle consent rating changes from participants
  /// This method is attempting to process and broadcast rating changes
  void _handleConsentRatingChange(ConsentRating rating) {
    if (AppConstants.isDebugMode) {
      _logger.i('🚦 Consent rating changed to: ${rating.name}');
    }

    // TODO: Broadcast rating change to all connected devices
    // This will be implemented with actual P2P communication

    _showSuccessMessage(
      'Consent level changed to ${rating.name.toUpperCase()}',
    );
  }

  /// Show dialog to confirm ending the session
  /// This method is attempting to prevent accidental session termination
  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text(
          'Are you sure you want to end this GameConsent session? '
          'All players will be disconnected and session data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endSession();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  /// End the current GameConsent session
  /// This method is attempting to properly clean up and terminate the session
  void _endSession() {
    if (AppConstants.isDebugMode) {
      _logger.i(
        '🔚 Ending GameConsent session: ${_sessionNameController.text}',
      );
    }

    // TODO: Disconnect all players and clean up Bluetooth resources

    setState(() {
      _sessionState = GameSessionState.ended;
    });

    // Navigate back to role selection or show session summary
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Show help dialog for session setup
  /// This method is attempting to provide user guidance
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Setup Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Creating a GameConsent Session:\n\n'
                '1. Choose a memorable session name that players will recognize\n\n'
                '2. Optionally enable password protection for private sessions\n\n'
                '3. Your device will advertise the session via Bluetooth\n\n'
                '4. Players can scan for and join your session\n\n'
                '5. Start consent monitoring when players are connected',
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

  /// Get list of important notes for Game Masters
  /// This method is attempting to provide helpful guidance
  List<String> _getImportantNotes() {
    return [
      'Your device must remain within Bluetooth range of all players throughout the session.',
      'Player ratings are anonymous - you won\'t know who sent each consent signal.',
      'All participants start at GREEN (comfortable) and can change the group level.',
      'When any participant signals YELLOW or RED, address the situation immediately.',
      'Keep your device charged as hosting requires continuous Bluetooth activity.',
      'If password protected, share the password verbally with authorized players only.',
    ];
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

  /// Show error dialog to user
  /// This method is attempting to handle error situations gracefully
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
