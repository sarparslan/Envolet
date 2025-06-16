import 'package:flutter/material.dart';

class AiSuggestionCard extends StatelessWidget {
  const AiSuggestionCard({
    super.key,
    required this.suggestion,
    this.isLoading = false,
  });

  final String suggestion;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.attach_money_rounded,
              color: Colors.lightBlue,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Envolet AI says:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  isLoading
                      ? const LinearProgressIndicator(minHeight: 2)
                      : Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
