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
  static const Color kNeonAccent = Color(0xFFFFFF00);
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final labsAsync = ref.watch(labsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            SearchAndFilterHeader(
              title: 'My Labs',
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No labs found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                            ),
                          ),
                        ],
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: const Text(
            'Filter Labs',
            style: TextStyle(color: Colors.white),
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
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNeonAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(
        Icons.check_circle_outline,
        color: kNeonAccent,
      ),
      onTap: () {
        // Implement filter logic
      },
    );
  }
}
