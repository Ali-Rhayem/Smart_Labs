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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final searchBarColor =
        isDarkMode ? const Color(0xFF1C1C1C) : Colors.grey.shade100;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: searchBarColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: textColor),
                  onPressed: onFilterPressed,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: searchBarColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: TextStyle(color: textColor),
              cursorColor: accentColor,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: textColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
              onChanged: onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }
}
