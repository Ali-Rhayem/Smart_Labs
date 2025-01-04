import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/screens/student/lab_details.dart';
import 'package:smart_labs_mobile/widgets/bottom_navigation_bar.dart';
import 'package:smart_labs_mobile/widgets/lab_card.dart';

class StudentLabsScreen extends StatefulWidget {
  StudentLabsScreen({super.key});

  // Example neon color (adjust as needed)
  static const Color kNeonAccent = Color(0xFFFFFF00);

  @override
  State<StudentLabsScreen> createState() => _StudentLabsScreenState();
}

class _StudentLabsScreenState extends State<StudentLabsScreen> {
  // Dummy data simulating labs from DB
  final List<Lab> sampleLabs = [
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

  @override
  Widget build(BuildContext context) {
    // Dark background
    return Scaffold(
      backgroundColor: Colors.black,
      // Custom “AppBar” area with the same style as your screenshot
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
      // Bottom navigation bar (to replicate the style in the mockup)
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
                    // TODO: implement filter action
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
              cursorColor: StudentLabsScreen.kNeonAccent,
              decoration: InputDecoration(
                hintText: 'Search Labs...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
              onChanged: (value) {
                // TODO: implement search logic
                print('Search query: $value');
                // filter labs for me based on search query
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabsList(BuildContext context) {
    return ListView.builder(
      itemCount: sampleLabs.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final lab = sampleLabs[index];
        return LabCard(lab: lab);
      },
    );
  }
}
