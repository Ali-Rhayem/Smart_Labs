import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';
import 'package:smart_labs_mobile/widgets/search_and_filter_header.dart';

class StudentLabsScreen extends ConsumerStatefulWidget {
  const StudentLabsScreen({super.key});

  @override
  ConsumerState<StudentLabsScreen> createState() => _StudentLabsScreenState();
}

class _StudentLabsScreenState extends ConsumerState<StudentLabsScreen> {
  static const Color kNeonAccent = Color(0xFFFFFF00);
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Detect app lifecycle changes
    AppLifecycleListener(
      onResume: () {
        print("App Resumed"); // App comes to the foreground
      },
      onInactive: () {
        print("App Inactive"); // Happens when switching apps
      },
      onPause: () {
        print("App Paused"); // App goes to the background
      },
      onDetach: () {
        print("App Detached (Closed)"); // App is killed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final labsAsync = ref.watch(labsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color.fromRGBO(18, 18, 18, 1) : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            SearchAndFilterHeader(
              title: 'Labs',
              backgroundColor:
                  isDarkMode ? const Color(0xFF121212) : Colors.white,
              accentColor: isDarkMode ? kNeonAccent : Colors.blue,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query.toLowerCase());
              },
              onFilterPressed: _showFilterDialog,
            ),
            Expanded(
              child: labsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? kNeonAccent : Colors.blue,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                data: (labs) {
                  final filteredLabs = labs.where((lab) {
                    return lab.labName.toLowerCase().contains(_searchQuery) ||
                        lab.labCode.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredLabs.isEmpty) {
                    return Center(
                      child: Text(
                        'No labs found',
                        style: TextStyle(
                          color: (isDarkMode ? Colors.white : Colors.black87)
                              .withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: isDarkMode ? kNeonAccent : Colors.blue,
                    onRefresh: () =>
                        ref.read(labsProvider.notifier).fetchLabs(),
                    child: ListView.builder(
                      itemCount: filteredLabs.length,
                      padding: const EdgeInsets.only(top: 8),
                      itemBuilder: (context, index) {
                        return LabCard(lab: filteredLabs[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF212121) : Colors.white,
          title: Text(
            'Filter Options',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Filter labs by date, instructor, etc.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: isDarkMode ? kNeonAccent : Colors.blue,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
