import 'package:flutter/material.dart';

/// A custom widget that displays two action buttons side-by-side.
///
/// Primary button supports optional validation before executing action.
class ActionButtonPair extends StatefulWidget {
  /// Validator for primary action (return false to stop execution)
  final bool Function()? primaryValidator;

  /// Callback triggered when primary button is pressed
  final Future<void> Function()? onPrimaryAction;

  /// Callback triggered when secondary button is pressed
  final Future<void> Function()? onSecondaryAction;

  final String primaryText;
  final String secondaryText;

  final Color primaryColor;
  final Color secondaryColor;

  final Color primaryTextColor;
  final Color secondaryTextColor;

  const ActionButtonPair({
    super.key,
    this.primaryValidator,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryText = 'Confirm',
    this.secondaryText = 'Cancel',
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

  Future<void> _handlePrimaryAction() async {
    if (_isProcessing) return;

    // 🔥 STEP 1: Validate BEFORE doing anything
    if (widget.primaryValidator != null) {
      final isValid = widget.primaryValidator!();
      if (!isValid) return; // 🚨 STOP HERE (no API call, no pop)
    }

    setState(() => _isProcessing = true);

    try {
      if (widget.onPrimaryAction != null) {
        await widget.onPrimaryAction!();
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleSecondaryAction() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (widget.onSecondaryAction != null) {
        await widget.onSecondaryAction!();
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
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
              disabledBackgroundColor:
              widget.primaryColor.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
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
