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

    return Scaffold(
      backgroundColor: const Color.fromRGBO(18, 18, 18, 1),
      body: SafeArea(
        child: Column(
          children: [
            SearchAndFilterHeader(
              title: 'Labs',
              backgroundColor: const Color(0xFF121212),
              accentColor: kNeonAccent,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query.toLowerCase());
              },
              onFilterPressed: _showFilterDialog,
            ),
            Expanded(
              child: labsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: kNeonAccent),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white),
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
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: kNeonAccent,
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: const Text('Filter labs by date, instructor, etc.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}
