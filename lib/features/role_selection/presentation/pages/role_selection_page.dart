// lib/features/role_selection/presentation/pages/role_selection_page.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Role selection screen for choosing between Game Master/Facilitator and Player roles
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Core imports for constants and enums
import 'package:gameconsentbasic/core/constants/app_constants.dart';
import 'package:gameconsentbasic/core/enums/app_enums.dart';

// TODO: Import BLoC when created
// import '../bloc/role_selection_bloc.dart';

// lib/features/role_selection/presentation/pages/role_selection_page.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Role selection screen for choosing between Game Master/Facilitator and Player roles
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

// TODO: Import BLoC when created
// import '../bloc/role_selection_bloc.dart';

/// Role Selection Page Widget
/// This page is attempting to provide users with a clear choice between
/// Game Master/Facilitator role and Player role at app startup
class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  /// Animation controller for page entrance animations
  /// This controller is trying to provide smooth visual transitions
  late AnimationController _animationController;

  /// Fade animation for the main content
  /// This animation is attempting to create a professional app entrance
  late Animation<double> _fadeAnimation;

  /// Scale animation for the role selection cards
  /// This animation is meant to draw attention to the user's choice
  late Animation<double> _scaleAnimation;

  /// Logger instance for debugging and tracking user interactions
  /// This logger is trying to help with development and user behavior analysis
  final Logger _logger = Logger();

  /// Currently selected user role (null until user makes a choice)
  /// This variable is attempting to track the user's selection state
  UserRole? _selectedRole;

  /// Whether the user has made a selection and is ready to proceed
  /// This flag is meant to control the continue button state
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with smooth timing
    // This setup is trying to create polished visual feedback
    _animationController = AnimationController(
      duration: AppConstants.slowAnimationDuration,
      vsync: this,
    );

    // Set up fade animation for page entrance
    // This animation is attempting to create a smooth app startup experience
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Set up scale animation for interactive elements
    // This animation is meant to provide visual feedback on user interactions
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Start the entrance animation
    // This is trying to create an engaging first impression
    _animationController.forward();

    // Log page initialization for debugging
    if (AppConstants.isDebugMode) {
      _logger.i('🎭 Role Selection Page initialized');
    }
  }

  @override
  void dispose() {
    // Clean up animation controller to prevent memory leaks
    // This disposal is attempting to maintain good memory management
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    // This calculation is trying to adapt to different device sizes
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > AppConstants.mobileBreakpoint;

    return Scaffold(
      // App bar with GameConsent branding
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // Main content with animated entrance
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMainContent(context, isLargeScreen),
            ),
          );
        },
      ),

      // Bottom action bar with continue button
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  /// Build the main content area with role selection cards
  /// This method is attempting to create an intuitive user interface
  Widget _buildMainContent(BuildContext context, bool isLargeScreen) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome header section
            _buildWelcomeHeader(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Role selection cards
            Expanded(child: _buildRoleSelectionCards(context, isLargeScreen)),

            const SizedBox(height: AppConstants.spacingLarge),

            // Information footer
            _buildInformationFooter(context),
          ],
        ),
      ),
    );
  }

  /// Build the welcome header with app branding and instructions
  /// This section is trying to orient users and explain the purpose
  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      children: [
        // App icon and title
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.traffic,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Welcome text
        Text(
          'Welcome to Game Consent',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.spacingSmall),

        // Instruction text
        Text(
          'Choose your role to get started with real-time consent management',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build the role selection cards with visual distinction
  /// This section is attempting to make the user's choice clear and appealing
  Widget _buildRoleSelectionCards(BuildContext context, bool isLargeScreen) {
    // Determine card layout based on screen size
    // This layout is trying to optimize for different device form factors
    if (isLargeScreen) {
      return Row(
        children: [
          Expanded(child: _buildRoleCard(context, UserRole.gameMaster)),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(child: _buildRoleCard(context, UserRole.player)),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: _buildRoleCard(context, UserRole.gameMaster)),
          const SizedBox(height: AppConstants.spacingMedium),
          Expanded(child: _buildRoleCard(context, UserRole.player)),
        ],
      );
    }
  }

  /// Build individual role selection card
  /// This method is attempting to create visually appealing and informative cards
  Widget _buildRoleCard(BuildContext context, UserRole role) {
    final bool isSelected = _selectedRole == role;
    final Color cardColor = isSelected
        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
        : Theme.of(context).colorScheme.surface;
    final Color borderColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline.withOpacity(0.3);

    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Role icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getRoleIcon(role),
                size: 30,
                color: _getRoleColor(role),
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Role title
            Text(
              role.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingSmall),

            // Role description
            Text(
              _getRoleDescription(role),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMedium,
                  vertical: AppConstants.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the information footer with version and help text
  /// This section is attempting to provide context and support information
  Widget _buildInformationFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'Version ${AppConstants.appVersion}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          'Need help? Visit ${AppConstants.supportUrl}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  /// Build the bottom action bar with continue button
  /// This section is trying to provide clear next-step navigation
  Widget _buildBottomActionBar(BuildContext context) {
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
            onPressed: _canProceed ? _proceedToNextStep : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _canProceed ? 'Continue' : 'Select Your Role',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle role selection logic
  /// This method is attempting to track user choice and update UI state
  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _canProceed = true;
    });

    // Log role selection for debugging and analytics
    if (AppConstants.isDebugMode) {
      _logger.i('👤 User selected role: ${role.displayName}');
    }

    // Provide haptic feedback for better user experience
    // This feedback is trying to confirm the user's selection
    // HapticFeedback.selectionClick(); // Uncomment when testing on device
  }

  /// Navigate to the next step based on selected role
  /// This method is attempting to route users to the appropriate workflow
  void _proceedToNextStep() {
    if (_selectedRole == null) return;

    // Log navigation for debugging
    if (AppConstants.isDebugMode) {
      _logger.i(
        '🚀 Proceeding to next step for role: ${_selectedRole!.displayName}',
      );
    }

    // Navigate based on selected role
    // This routing is trying to direct users to the appropriate setup process
    switch (_selectedRole!) {
      case UserRole.gameMaster:
        // Navigate to Game Master setup (permissions and session creation)
        _navigateToGameMasterSetup();
        break;
      case UserRole.player:
        // Navigate to Player setup (permissions and session joining)
        _navigateToPlayerSetup();
        break;
    }
  }

  /// Navigate to Game Master setup workflow
  /// This method is attempting to handle the GM/Facilitator path
  void _navigateToGameMasterSetup() {
    // Navigate to permissions screen for hosting capabilities
    Navigator.pushNamed(context, '/gm-permissions');
  }

  /// Navigate to Player setup workflow
  /// This method is attempting to handle the Player path
  void _navigateToPlayerSetup() {
    // Navigate to permissions screen for joining capabilities
    Navigator.pushNamed(context, '/player-permissions');
  }

  /// Get appropriate icon for each user role
  /// This method is attempting to provide visual distinction between roles
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.gameMaster:
        return Icons.admin_panel_settings;
      case UserRole.player:
        return Icons.person;
    }
  }

  /// Get appropriate color for each user role
  /// This method is trying to use consistent color coding throughout the app
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.gameMaster:
        return const Color(0xFF4CAF50); // Green for authority/control
      case UserRole.player:
        return const Color(0xFF2196F3); // Blue for participation
    }
  }

  /// Get descriptive text for each user role
  /// This method is attempting to help users understand their choice
  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.gameMaster:
        return 'Host and manage a GameConsent session. See all player ratings and control the session.';
      case UserRole.player:
        return 'Join an existing GameConsent session. Send anonymous consent ratings to the Game Master.';
    }
  }
}
