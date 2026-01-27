import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinCodeDialog extends StatefulWidget {
  const PinCodeDialog({super.key});

  @override
  State<PinCodeDialog> createState() => _PinCodeDialogState();
}

class _PinCodeDialogState extends State<PinCodeDialog> {
  @override
  Widget build(BuildContext context) {
    // Primary color from your portal's theme
    const primaryColor = Color(0xFF005B96); 
    const textColor = Color(0xFF2D3142);

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.grey.shade200,
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // This prevents the vertical stretching
          children: [
            // Security Icon
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFE8F0FE),
              child: Icon(Icons.lock_outline_rounded, color: primaryColor, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              "PIN අංකය ඇතුලත් කරන්න",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ඇතුළු වීමට ඔබගේ ඉලක්කම් 4ක PIN අංකය යොදන්න",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Pinput(
              length: 4,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              obscureText: true,
              obscuringCharacter: "●",
              autofocus: true,
              showCursor: true,
              onCompleted: (pin) => Navigator.of(context).pop(pin),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}