import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/data/mock_labs.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';
import 'package:smart_labs_mobile/widgets/search_and_filter_header.dart';

class StudentLabsScreen extends StatefulWidget {
  const StudentLabsScreen({super.key});

  @override
  State<StudentLabsScreen> createState() => _StudentLabsScreenState();
}

class _StudentLabsScreenState extends State<StudentLabsScreen> {
  // Example neon color (adjust as needed)
  static const Color kNeonAccent = Color(0xFFFFFF00);

  final List<Lab> _allLabs = mockLabs;

  // This list will be updated as user types in the search bar.
  late List<Lab> _filteredLabs;

  @override
  void initState() {
    super.initState();
    // Initially, show all labs
    _filteredLabs = List.from(_allLabs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background
      // backgroundColor: Colors.black,
      backgroundColor: const Color.fromRGBO(18, 18, 18, 1),
      body: SafeArea(
        child: Column(
          children: [
            // Reusable header
            SearchAndFilterHeader(
              title: 'Labs',
              // backgroundColor: Colors.black,
              backgroundColor: const Color(0xFF121212),
              accentColor: kNeonAccent,
              onSearchChanged: _filterLabs,
              onFilterPressed: _showFilterDialog,
            ),
            // Labs list
            Expanded(child: _buildLabsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabsList(BuildContext context) {
    return ListView.builder(
      itemCount: _filteredLabs.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final lab = _filteredLabs[index];
        return LabCard(lab: lab);
      },
    );
  }

  // Simple filtering logic, can be expanded
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
