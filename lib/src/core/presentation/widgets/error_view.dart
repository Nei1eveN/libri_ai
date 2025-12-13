import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.error,
    this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cute "Broken" Icon
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
            const Gap(16),

            // Friendly Title
            const Text(
              "Connection Drifted",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8),

            // The actual error (cleaned up slightly)
            Text(
              _cleanError(error),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Gap(24),

            // Retry Button
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
          ],
        ),
      ),
    );
  }

  String _cleanError(Object err) {
    final str = err.toString();
    if (str.contains("SocketException")) {
      return "Check your internet connection.";
    }
    if (str.contains("404")) return "We couldn't find that.";
    // Clean up the "Exception: ..." prefix
    return str.replaceAll("Exception:", "").trim();
  }
}
