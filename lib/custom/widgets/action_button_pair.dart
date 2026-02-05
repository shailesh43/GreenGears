import 'package:flutter/material.dart';

/// A custom widget that displays two action buttons side-by-side.
///
/// Displays two buttons (primary and secondary) that trigger their respective
/// callbacks and show snackbar messages. Automatically closes the current
/// screen when either button is pressed.
///
/// Common use cases: Approve/Reject, Submit/Cancel, Save/Discard, Confirm/Cancel
class ActionButtonPair extends StatefulWidget {
  /// Callback function triggered when primary (left) button is pressed
  final VoidCallback? onPrimaryAction;

  /// Callback function triggered when secondary (right) button is pressed
  final VoidCallback? onSecondaryAction;

  /// Text for the primary button (defaults to 'Confirm')
  final String primaryText;

  /// Text for the secondary button (defaults to 'Cancel')
  final String secondaryText;

  /// Message shown in snackbar when primary action is triggered
  final String? primaryMessage;

  /// Message shown in snackbar when secondary action is triggered
  final String? secondaryMessage;

  /// Background color for primary button (defaults to green)
  final Color primaryColor;

  /// Background color for secondary button (defaults to light red)
  final Color secondaryColor;

  /// Text color for primary button (defaults to white)
  final Color primaryTextColor;

  /// Text color for secondary button (defaults to red)
  final Color secondaryTextColor;

  const ActionButtonPair({
    super.key,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryText = 'Confirm',
    this.secondaryText = 'Cancel',
    this.primaryMessage,
    this.secondaryMessage,
    this.primaryColor = const Color(0xFFD7FFD8),
    this.secondaryColor = const Color(0xFFFFE3E3),
    this.primaryTextColor = const Color(0xFF3E8942),
    this.secondaryTextColor = const Color(0xFF8B3C3C),
  });

  @override
  State<ActionButtonPair> createState() => ActionButtonPairState();
}

class ActionButtonPairState extends State<ActionButtonPair> {
  bool _isProcessing = false;

  void _handlePrimaryAction() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Call the onPrimaryAction callback if provided
    widget.onPrimaryAction?.call();

    // Close the current screen
    if (mounted) {
      Navigator.pop(context);

      // Show snackbar if message is provided
      if (widget.primaryMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.primaryMessage!,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF388E3B),
              ),
            ),
            backgroundColor: const Color(0xFFD7FFD8),
          ),
        );
      }
    }
  }

  void _handleSecondaryAction() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Call the onSecondaryAction callback if provided
    widget.onSecondaryAction?.call();

    // Close the current screen
    if (mounted) {
      Navigator.pop(context);

      // Show snackbar if message is provided
      if (widget.secondaryMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.secondaryMessage!,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFFFA6262),
              ),
            ),
            backgroundColor: const Color(0xFFFFE3E3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSecondary = widget.onSecondaryAction != null;

    return Row(
      mainAxisAlignment:
      showSecondary ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        Expanded(
          flex: showSecondary ? 1 : 2,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handlePrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
              disabledBackgroundColor: widget.primaryColor.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Text(
              widget.primaryText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.primaryTextColor,
              ),
            ),
          ),
        ),

        if (showSecondary) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleSecondaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.secondaryColor,
                disabledBackgroundColor:
                widget.secondaryColor.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                widget.secondaryText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

}