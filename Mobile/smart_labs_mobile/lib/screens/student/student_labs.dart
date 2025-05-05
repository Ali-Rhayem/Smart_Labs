import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/semester_provider.dart';
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
  String? _selectedSemesterId;

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
                    // Text search filter
                    final matchesSearch =
                        lab.labName.toLowerCase().contains(_searchQuery) ||
                            lab.labCode.toLowerCase().contains(_searchQuery);

                    // Semester filter
                    final matchesSemester = _selectedSemesterId == null ||
                        lab.semesterId == _selectedSemesterId;

                    return matchesSearch && matchesSemester;
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  isDarkMode ? const Color(0xFF212121) : Colors.white,
              title: Text(
                'Filter Labs',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final semestersAsync = ref.watch(semestersProvider);
                      return semestersAsync.when(
                        loading: () => CircularProgressIndicator(
                          color: isDarkMode ? kNeonAccent : Colors.blue,
                        ),
                        error: (error, stack) => Text('Error: $error'),
                        data: (semesters) => DropdownButtonFormField<String>(
                          value: _selectedSemesterId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode
                                ? const Color(0xFF2C2C2C)
                                : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Semesters'),
                            ),
                            ...semesters.map((semester) {
                              return DropdownMenuItem(
                                value: semester.id.toString(),
                                child: Text(semester.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSemesterId = value);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSemesterId = null;
                    });
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? kNeonAccent : Colors.blue,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
