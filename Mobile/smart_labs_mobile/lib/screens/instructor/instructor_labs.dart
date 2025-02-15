import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';
import 'package:smart_labs_mobile/widgets/search_and_filter_header.dart';

class DoctorLabsScreen extends ConsumerStatefulWidget {
  const DoctorLabsScreen({super.key});

  @override
  ConsumerState<DoctorLabsScreen> createState() => _DoctorLabsScreenState();
}

class _DoctorLabsScreenState extends ConsumerState<DoctorLabsScreen> {
  String _searchQuery = '';

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
                    return lab.labName.toLowerCase().contains(_searchQuery) ||
                        lab.labCode.toLowerCase().contains(_searchQuery);
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
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
          title: Text(
            'Filter Labs',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Active Labs'),
              _buildFilterOption('Completed Labs'),
              _buildFilterOption('Upcoming Labs'),
            ],
          ),
          actions: [
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
              onPressed: () => Navigator.of(context).pop(),
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
  }

  Widget _buildFilterOption(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      trailing: Icon(
        Icons.check_circle_outline,
        color: isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
      ),
      onTap: () {
        // Implement filter logic
      },
    );
  }
}
