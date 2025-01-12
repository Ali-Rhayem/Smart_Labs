import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/data/mock_labs.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';
import 'package:smart_labs_mobile/widgets/search_and_filter_header.dart';

class DoctorLabsScreen extends StatefulWidget {
  const DoctorLabsScreen({super.key});

  @override
  State<DoctorLabsScreen> createState() => _DoctorLabsScreenState();
}

class _DoctorLabsScreenState extends State<DoctorLabsScreen> {
  static const Color kNeonAccent = Color(0xFFFFFF00);
  final List<Lab> _allLabs = mockLabs;
  late List<Lab> _filteredLabs;

  @override
  void initState() {
    super.initState();
    _filteredLabs = List.from(_allLabs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            SearchAndFilterHeader(
              title: 'My Labs',
              backgroundColor: const Color(0xFF121212),
              accentColor: kNeonAccent,
              onSearchChanged: _filterLabs,
              onFilterPressed: _showFilterDialog,
            ),
            Expanded(child: _buildLabsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabsList(BuildContext context) {
    if (_filteredLabs.isEmpty) {
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

    return ListView.builder(
      itemCount: _filteredLabs.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final lab = _filteredLabs[index];
        return LabCard(
          lab: lab,
          showManageButton: true,
        );
      },
    );
  }

  void _filterLabs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLabs = List.from(_allLabs);
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredLabs = _allLabs.where((lab) {
          final nameMatch = lab.labName.toLowerCase().contains(lowerQuery);
          final codeMatch = lab.labCode.toLowerCase().contains(lowerQuery);
          return nameMatch || codeMatch;
        }).toList();
      }
    });
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