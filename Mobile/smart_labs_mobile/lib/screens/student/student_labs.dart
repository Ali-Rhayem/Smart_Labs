import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/screens/student/lab_details.dart';
import 'package:smart_labs_mobile/widgets/bottom_navigation_bar.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';

class StudentLabsScreen extends StatefulWidget {
  const StudentLabsScreen({Key? key}) : super(key: key);

  @override
  State<StudentLabsScreen> createState() => _StudentLabsScreenState();
}

class _StudentLabsScreenState extends State<StudentLabsScreen> {
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
    // Dark background
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header with title, search bar, filter icon
            _buildHeader(context),
            // Labs list
            Expanded(child: _buildLabsList(context)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          // Page Title
          Row(
            children: [
              Text(
                'Labs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Filter Icon
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: implement filter action (e.g., by date, by instructor, etc.)
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: kNeonAccent,
              decoration: InputDecoration(
                hintText: 'Search Labs...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
              onChanged: (query) {
                // Filter labs whenever user types
                _filterLabs(query);
              },
            ),
          ),
        ],
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
        // If search is empty, show all labs again
        _filteredLabs = List.from(_allLabs);
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredLabs = _allLabs.where((lab) {
          // For example, search by name or code
          final nameMatch = lab.labName.toLowerCase().contains(lowerQuery);
          final codeMatch = lab.labCode.toLowerCase().contains(lowerQuery);
          return nameMatch || codeMatch;
        }).toList();
      }
    });
  }
}
