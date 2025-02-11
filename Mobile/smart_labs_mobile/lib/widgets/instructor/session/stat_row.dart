import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // Extract percentage value and convert to double
    final percentage = double.tryParse(value.replaceAll('%', '')) ?? 0.0;

    // Calculate color based on percentage
    Color percentageColor;
    if (percentage >= 90) {
      percentageColor = Colors.green[400]!;
    } else if (percentage >= 70) {
      percentageColor = Colors.yellow[600]!;
    } else if (percentage >= 50) {
      percentageColor = Colors.orange;
    } else {
      percentageColor = Colors.red[400]!;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: percentageColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: percentageColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: percentageColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                percentage >= 90
                    ? Icons.check_circle
                    : percentage >= 70
                        ? Icons.info
                        : percentage >= 50
                            ? Icons.warning
                            : Icons.error,
                size: 16,
                color: percentageColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}