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
  final Future<void> Function()? onPrimaryAction;

  /// Callback function triggered when secondary (right) button is pressed
  final Future<void> Function()? onSecondaryAction;

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

    if (widget.onPrimaryAction != null) {
      await widget.onPrimaryAction!();
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });
  }

  void _handleSecondaryAction() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    widget.onSecondaryAction?.call();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });
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