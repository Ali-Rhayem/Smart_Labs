import 'package:flutter/material.dart';

class RowDetails extends StatelessWidget {
  final String label;
  final String value;
  const RowDetails({super.key, required this.label, required this.value});

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
