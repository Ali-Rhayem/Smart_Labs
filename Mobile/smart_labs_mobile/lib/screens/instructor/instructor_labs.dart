import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/semester_provider.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';
import 'package:smart_labs_mobile/widgets/search_and_filter_header.dart';

class DoctorLabsScreen extends ConsumerStatefulWidget {
  const DoctorLabsScreen({super.key});

  @override
  ConsumerState<DoctorLabsScreen> createState() => _DoctorLabsScreenState();
}

class _DoctorLabsScreenState extends ConsumerState<DoctorLabsScreen> {
  String _searchQuery = '';
  String? _selectedSemesterId;
  bool _showActiveLabs = false;
  bool _showCompletedLabs = false;
  bool _showUpcomingLabs = false;

  @override
  Widget build(BuildContext context) {
    final labsAsync = ref.watch(labsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SearchAndFilterHeader(
              title: 'My Labs',
              backgroundColor:
                  isDark ? const Color(0xFF121212) : theme.colorScheme.surface,
              accentColor:
                  isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query.toLowerCase());
              },
              onFilterPressed: _showFilterDialog,
            ),
            Expanded(
              child: labsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: isDark
                        ? const Color(0xFFFFFF00)
                        : theme.colorScheme.primary,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
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

                    // Status filters
                    bool matchesStatus = true;
                    if (_showActiveLabs ||
                        _showCompletedLabs ||
                        _showUpcomingLabs) {
                      matchesStatus = false;
                      if (_showActiveLabs && lab.started) {
                        matchesStatus = true;
                      }
                      if (_showCompletedLabs && lab.sessions.isNotEmpty) {
                        matchesStatus = true;
                      }
                      if (_showUpcomingLabs && !lab.started) {
                        matchesStatus = true;
                      }
                    }

                    return matchesSearch && matchesSemester && matchesStatus;
                  }).toList();

                  if (filteredLabs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 64,
                            color:
                                theme.colorScheme.onBackground.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No labs found',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground
                                  .withValues(alpha: 0.7),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: isDark
                        ? const Color(0xFFFFFF00)
                        : theme.colorScheme.primary,
                    onRefresh: () =>
                        ref.read(labsProvider.notifier).fetchLabs(),
                    child: ListView.builder(
                      itemCount: filteredLabs.length,
                      padding: const EdgeInsets.only(top: 8),
                      itemBuilder: (context, index) {
                        final lab = filteredLabs[index];
                        return LabCard(
                          lab: lab,
                          showManageButton: true,
                        );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
              title: Text(
                'Filter Labs',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final semestersAsync = ref.watch(semestersProvider);
                      return semestersAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                        data: (semesters) => DropdownButtonFormField<String>(
                          value: _selectedSemesterId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF2C2C2C)
                                : theme.colorScheme.surface,
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
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    'Active Labs',
                    _showActiveLabs,
                    (value) => setState(() => _showActiveLabs = value),
                  ),
                  _buildFilterOption(
                    'Completed Labs',
                    _showCompletedLabs,
                    (value) => setState(() => _showCompletedLabs = value),
                  ),
                  _buildFilterOption(
                    'Upcoming Labs',
                    _showUpcomingLabs,
                    (value) => setState(() => _showUpcomingLabs = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSemesterId = null;
                      _showActiveLabs = false;
                      _showCompletedLabs = false;
                      _showUpcomingLabs = false;
                    });
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFFFFFF00)
                        : theme.colorScheme.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
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

  Widget _buildFilterOption(
      String title, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      value: value,
      activeColor: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
      onChanged: (newValue) => onChanged(newValue ?? false),
    );
  }
}
