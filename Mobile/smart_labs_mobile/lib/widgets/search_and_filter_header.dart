import 'package:flutter/material.dart';

class SearchAndFilterHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color accentColor;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;

  const SearchAndFilterHeader({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.accentColor,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          // Title + Filter Icon Row
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1C1C),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  color: Colors.white,
                  onPressed: onFilterPressed,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: accentColor,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
              onChanged: (value) => onSearchChanged(value),
            ),
          ),
        ],
      ),
    );
  }
}
