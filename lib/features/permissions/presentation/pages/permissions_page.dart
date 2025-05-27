// lib/features/permissions/presentation/pages/permissions_page.dart
// Game Consent Basic App - Pre-Alpha 1 (0.0.1+005251130)
// Bluetooth permissions handling screen for both Game Master and Player workflows
// Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming"

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

// Core imports for constants and enums
import 'package:gameconsentbasic/core/constants/app_constants.dart';
import 'package:gameconsentbasic/core/enums/app_enums.dart';

/// Permissions page for handling Bluetooth and related device permissions
/// This page is attempting to guide users through the permission grant process
/// required for P2P Bluetooth functionality in the GameConsent app
class PermissionsPage extends StatefulWidget {
  /// Constructor requiring user role to customize permission explanations
  /// This constructor is trying to provide role-specific permission guidance
  const PermissionsPage({super.key, required this.userRole});

  /// The user role (GM or Player) to customize the permission flow
  /// This role is meant to determine what permissions are needed and why
  final UserRole userRole;

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with TickerProviderStateMixin {
  /// Logger instance for debugging permission flows
  /// This logger is attempting to track permission request outcomes
  final Logger _logger = Logger();

  /// Animation controller for permission status updates
  /// This controller is trying to provide smooth visual feedback
  late AnimationController _animationController;

  /// Fade animation for permission status changes
  /// This animation is meant to make status updates feel responsive
  late Animation<double> _fadeAnimation;

  /// Current state of each required permission
  /// This map is attempting to track all permission states centrally
  final Map<Permission, PermissionState> _permissionStates = {};

  /// Whether all required permissions have been granted
  /// This flag is trying to control the continue button state
  bool _allPermissionsGranted = false;

  /// Whether a permission request is currently in progress
  /// This flag is meant to prevent multiple simultaneous requests
  bool _requestInProgress = false;

  /// List of permissions required for this user role
  /// These permissions are attempting to enable Bluetooth P2P functionality
  late List<Permission> _requiredPermissions;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth transitions
    // This setup is trying to create polished permission status updates
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Determine required permissions based on user role
    // This setup is attempting to request only necessary permissions
    _setupRequiredPermissions();

    // Check current permission status on page load
    // This check is trying to handle cases where permissions were previously granted
    _checkCurrentPermissions();

    // Start entrance animation
    _animationController.forward();

    // Log permissions page initialization
    if (AppConstants.isDebugMode) {
      _logger.i(
        '🔐 Permissions page initialized for role: ${widget.userRole.displayName}',
      );
    }
  }

  @override
  void dispose() {
    // Clean up animation controller to prevent memory leaks
    _animationController.dispose();
    super.dispose();
  }

  /// Setup required permissions based on user role
  /// This method is attempting to customize permission requests by role
  void _setupRequiredPermissions() {
    // Base permissions needed for all roles
    // These permissions are trying to enable basic Bluetooth functionality
    _requiredPermissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location, // Required for Bluetooth scanning on Android and iOS
      Permission.notification, // For consent status change notifications
    ];

    // Additional permissions for Game Master role
    // These permissions are meant to enable hosting/advertising capabilities
    if (widget.userRole == UserRole.gameMaster) {
      _requiredPermissions.addAll([
        Permission
            .location, // Required for Bluetooth scanning on some Android versions
      ]);
    }

    // Initialize permission states to unknown
    // This initialization is attempting to track each permission individually
    for (Permission permission in _requiredPermissions) {
      _permissionStates[permission] = PermissionState.unknown;
    }
  }

  /// Check current status of all required permissions
  /// This method is attempting to determine what permissions are already granted
  Future<void> _checkCurrentPermissions() async {
    try {
      // Check each required permission individually
      // This loop is trying to get accurate status for each permission
      for (Permission permission in _requiredPermissions) {
        final PermissionStatus status = await permission.status;
        setState(() {
          _permissionStates[permission] = _mapPermissionStatus(status);
        });
      }

      // Update overall permission state
      // This check is attempting to determine if we can proceed
      _updateOverallPermissionState();

      if (AppConstants.isDebugMode) {
        _logger.d(
          '📋 Permission check completed: ${_permissionStates.length} permissions checked',
        );
      }
    } catch (e) {
      _logger.e('❌ Error checking permissions: $e');
      // Handle permission check errors gracefully
      _showErrorDialog(
        'Permission Check Failed',
        'Unable to check current permissions. Please try again.',
      );
    }
  }

  /// Map PermissionStatus to our PermissionState enum
  /// This method is attempting to convert between permission_handler and our enums
  PermissionState _mapPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionState.granted;
      case PermissionStatus.denied:
        return PermissionState.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionState.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionState.restricted;
      default:
        return PermissionState.unknown;
    }
  }

  /// Update the overall permission granted state
  /// This method is attempting to determine if all required permissions are available
  void _updateOverallPermissionState() {
    final bool allGranted = _permissionStates.values.every(
      (state) => state == PermissionState.granted,
    );

    setState(() {
      _allPermissionsGranted = allGranted;
    });

    if (AppConstants.isDebugMode) {
      _logger.d('✅ All permissions granted: $allGranted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with role-specific title
      appBar: AppBar(
        title: Text('${widget.userRole.displayName} Setup'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      // Main content with permission explanations and controls
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildMainContent(context),
          );
        },
      ),

      // Bottom action bar with permission request and continue buttons
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  /// Build the main content area with permission explanations
  /// This method is attempting to educate users about why permissions are needed
  Widget _buildMainContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with role-specific explanation
            _buildHeaderSection(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Permission requirements section
            _buildPermissionRequirements(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Permission status list
            _buildPermissionStatusList(context),

            const SizedBox(height: AppConstants.spacingXLarge),

            // Help and troubleshooting section
            _buildHelpSection(context),
          ],
        ),
      ),
    );
  }

  /// Build the header section with role-specific explanation
  /// This section is attempting to explain why permissions are needed for each role
  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Permission icon and title
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.security,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Permissions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Required for Bluetooth P2P functionality',
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

        const SizedBox(height: AppConstants.spacingLarge),

        // Role-specific explanation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getRolePermissionTitle(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                _getRolePermissionExplanation(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the permission requirements explanation
  /// This section is attempting to detail what each permission enables
  Widget _buildPermissionRequirements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Permissions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // List of permission explanations
        ...(_getPermissionExplanations().map(
          (explanation) =>
              _buildPermissionExplanationItem(context, explanation),
        )),
      ],
    );
  }

  /// Build individual permission explanation item
  /// This method is attempting to explain each permission clearly
  Widget _buildPermissionExplanationItem(
    BuildContext context,
    Map<String, String> explanation,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation['title']!,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  explanation['description']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }

  /// Build the permission status list showing current state
  /// This section is attempting to provide real-time permission status feedback
  Widget _buildPermissionStatusList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permission Status',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // Status list for each permission
        ...(_requiredPermissions.map(
          (permission) => _buildPermissionStatusItem(context, permission),
        )),
      ],
    );
  }

  /// Build individual permission status item
  /// This method is attempting to show current status of each permission
  Widget _buildPermissionStatusItem(
    BuildContext context,
    Permission permission,
  ) {
    final PermissionState state =
        _permissionStates[permission] ?? PermissionState.unknown;
    final Color statusColor = _getPermissionStatusColor(state);
    final IconData statusIcon = _getPermissionStatusIcon(state);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPermissionDisplayName(permission),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  state.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build help and troubleshooting section
  /// This section is attempting to provide user support for permission issues
  Widget _buildHelpSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                'Need Help?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'If permissions are permanently denied, you may need to enable them manually in your device settings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          GestureDetector(
            onTap: _openAppSettings,
            child: Text(
              'Open App Settings',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the bottom action bar with permission and continue buttons
  /// This section is attempting to provide clear next-step actions
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Request permissions button
            if (!_allPermissionsGranted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestInProgress ? null : _requestAllPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingMedium,
                    ),
                  ),
                  child: _requestInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Grant Permissions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

            // Continue button (only shown when all permissions are granted)
            if (_allPermissionsGranted) ...[
              if (!_allPermissionsGranted)
                const SizedBox(height: AppConstants.spacingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToNextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingMedium,
                    ),
                  ),
                  child: Text(
                    _allPermissionsGranted
                        ? 'Continue to Setup'
                        : 'Grant Permissions First',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Request all required permissions
  /// This method is attempting to handle the permission request flow
  Future<void> _requestAllPermissions() async {
    if (_requestInProgress) return;

    setState(() {
      _requestInProgress = true;
    });

    try {
      // Request each permission individually for better error handling
      // This approach is trying to handle partial permission grants gracefully
      for (Permission permission in _requiredPermissions) {
        if (_permissionStates[permission] != PermissionState.granted) {
          final PermissionStatus status = await permission.request();
          setState(() {
            _permissionStates[permission] = _mapPermissionStatus(status);
          });

          if (AppConstants.isDebugMode) {
            _logger.d(
              '📱 Permission ${_getPermissionDisplayName(permission)}: ${status.name}',
            );
          }
        }
      }

      // Update overall permission state
      _updateOverallPermissionState();

      // Provide user feedback
      if (_allPermissionsGranted) {
        _showSuccessMessage('All permissions granted successfully!');
      } else {
        _showWarningMessage(
          'Some permissions were not granted. Please try again or check your device settings.',
        );
      }
    } catch (e) {
      _logger.e('❌ Error requesting permissions: $e');
      _showErrorDialog(
        'Permission Request Failed',
        'Unable to request permissions. Please try again or check your device settings.',
      );
    } finally {
      setState(() {
        _requestInProgress = false;
      });
    }
  }

  /// Open device app settings for manual permission management
  /// This method is attempting to help users with permanently denied permissions
  Future<void> _openAppSettings() async {
    try {
      final bool opened = await openAppSettings();
      if (!opened) {
        _showErrorDialog(
          'Settings Unavailable',
          'Unable to open app settings. Please navigate to your device settings manually.',
        );
      }
    } catch (e) {
      _logger.e('❌ Error opening app settings: $e');
    }
  }

  /// Proceed to the next step in the user flow
  /// This method is attempting to route users to role-specific setup screens
  void _proceedToNextStep() {
    if (!_allPermissionsGranted) return;

    if (AppConstants.isDebugMode) {
      _logger.i(
        '🚀 Proceeding to next step for role: ${widget.userRole.displayName}',
      );
    }

    // Navigate based on user role
    switch (widget.userRole) {
      case UserRole.gameMaster:
        _navigateToGameMasterSetup();
        break;
      case UserRole.player:
        _navigateToPlayerSetup();
        break;
    }
  }

  /// Navigate to Game Master session setup
  /// This method is attempting to handle the GM workflow
  void _navigateToGameMasterSetup() {
    // Navigate to GM session creation screen
    Navigator.pushReplacementNamed(context, '/gm-session-setup');
  }

  /// Navigate to Player session joining
  /// This method is attempting to handle the Player workflow
  void _navigateToPlayerSetup() {
    // Navigate to Player session joining screen
    Navigator.pushReplacementNamed(context, '/player-session-join');
  }

  /// Get role-specific permission explanation title
  /// This method is attempting to customize explanations by user role
  String _getRolePermissionTitle() {
    switch (widget.userRole) {
      case UserRole.gameMaster:
        return 'Game Master Permissions';
      case UserRole.player:
        return 'Player Permissions';
    }
  }

  /// Get role-specific permission explanation text
  /// This method is attempting to explain why each role needs permissions
  String _getRolePermissionExplanation() {
    switch (widget.userRole) {
      case UserRole.gameMaster:
        return 'As a Game Master, you need these permissions to host a GameConsent session. Your device will advertise the session so players can find and join it via Bluetooth.';
      case UserRole.player:
        return 'As a Player, you need these permissions to find and join GameConsent sessions hosted by Game Masters in your area via Bluetooth.';
    }
  }

  /// Get list of permission explanations for UI display
  /// This method is attempting to provide user-friendly permission descriptions
  List<Map<String, String>> _getPermissionExplanations() {
    return [
      {
        'title': 'Bluetooth Access',
        'description':
            'Connect to other devices running GameConsent for real-time communication.',
      },
      {
        'title': 'Device Discovery',
        'description':
            'Find nearby GameConsent sessions to join or advertise your own session.',
      },
      {
        'title': 'Secure Communication',
        'description':
            'Send and receive consent ratings securely between devices.',
      },
      if (widget.userRole == UserRole.gameMaster)
        {
          'title': 'Location Services',
          'description':
              'Required on some Android versions for Bluetooth device scanning.',
        },
    ];
  }

  /// Get display name for permission
  /// This method is attempting to provide user-friendly permission names
  String _getPermissionDisplayName(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
        return 'Bluetooth';
      case Permission.bluetoothScan:
        return 'Bluetooth Scanning';
      case Permission.bluetoothConnect:
        return 'Bluetooth Connection';
      case Permission.bluetoothAdvertise:
        return 'Bluetooth Advertising';
      case Permission.location:
        return 'Location Services';
      default:
        return 'Unknown Permission';
    }
  }

  /// Get color for permission status display
  /// This method is attempting to provide visual status indicators
  Color _getPermissionStatusColor(PermissionState state) {
    switch (state) {
      case PermissionState.granted:
        return Colors.green;
      case PermissionState.denied:
      case PermissionState.permanentlyDenied:
        return Colors.red;
      case PermissionState.restricted:
        return Colors.orange;
      case PermissionState.unknown:
        return Colors.grey;
    }
  }

  /// Get icon for permission status display
  /// This method is attempting to provide visual status indicators
  IconData _getPermissionStatusIcon(PermissionState state) {
    switch (state) {
      case PermissionState.granted:
        return Icons.check_circle;
      case PermissionState.denied:
      case PermissionState.permanentlyDenied:
        return Icons.cancel;
      case PermissionState.restricted:
        return Icons.warning;
      case PermissionState.unknown:
        return Icons.help;
    }
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

  /// Show warning message to user
  /// This method is attempting to provide cautionary feedback
  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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
