import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/widgets/bottom_navigation_bar.dart';
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

  // Dummy data simulating labs from DB
  final List<Lab> _allLabs = [
    Lab(
      labId: '1',
      labCode: 'CHEM101',
      labName: 'Intro to Chemistry',
      description: 'Lab safety & fundamentals',
      ppe: 'Gloves, Goggles',
      instructors: ['Dr. Smith', 'Dr. Johnson'],
      students: ['John Doe', 'Jane Smith'],
      date: DateTime(2023, 5, 10),
      startTime: '09:00 AM',
      endTime: '11:00 AM',
      report: 'N/A',
      semesterId: 'SEM2023A',
    ),
    Lab(
      labId: '2',
      labCode: 'BIO202',
      labName: 'Advanced Biology',
      description: 'Dissection & microscope usage',
      ppe: 'Lab Coat, Gloves, Goggles',
      instructors: ['Dr. Brown'],
      students: ['Alice Green', 'Bob Grey'],
      date: DateTime(2023, 5, 12),
      startTime: '01:00 PM',
      endTime: '03:30 PM',
      report: 'N/A',
      semesterId: 'SEM2023A',
    ),
  ];

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Reusable header
            SearchAndFilterHeader(
              title: 'Labs',
              backgroundColor: Colors.black,
              accentColor: kNeonAccent,
              onSearchChanged: _filterLabs,
              onFilterPressed: _showFilterDialog,
            ),
            // Labs list
            Expanded(child: _buildLabsList(context)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
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
