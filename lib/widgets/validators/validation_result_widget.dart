import 'package:flutter/material.dart';
import '../../models/brd_validator_model.dart';

class ValidationResultWidget extends StatelessWidget {
  final BRDValidationResult? result;
  final VoidCallback onRetry;

  const ValidationResultWidget({
    Key? key,
    required this.result,
    required this.onRetry,
  }) : super(key: key);

  // Helper method to switch to form tab
  void _switchToFormTab(BuildContext context) {
    // Get the parent tab controller
    final tabController = DefaultTabController.of(context);
    if (tabController != null) {
      tabController.animateTo(0); // Switch to form tab
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result!.isPassed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result!.isPassed ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                result!.isPassed ? Icons.check_circle : Icons.error,
                color: result!.isPassed ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result!.isPassed ? 'PASS' : 'FAIL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: result!.isPassed ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result!.message,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          if (result!.improvementSuggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Suggestions for Improvement:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...result!.improvementSuggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (!result!.isPassed) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _switchToFormTab(context);
                // Call onRetry as a fallback if switching tabs fails
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
              ),
              child: const Text('Edit in Form Tab'),
            ),
          ],
        ],
      ),
    );
  }
} 