import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/widgets/instructor/analytics_tab.dart';
import 'package:smart_labs_mobile/widgets/instructor/announcements_tab.dart';
import 'package:smart_labs_mobile/widgets/instructor/lab_header.dart';
import 'package:smart_labs_mobile/widgets/instructor/people_tab.dart';
import 'package:smart_labs_mobile/widgets/instructor/sessions_tab.dart';

var logger = Logger();

class InstructorLabDetailScreen extends StatelessWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);
  const InstructorLabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Lab Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit lab functionality
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabHeader(lab: lab),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: kNeonAccent,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: kNeonAccent,
                dividerColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Sessions'),
                  Tab(text: 'People'),
                  Tab(text: 'Analytics'),
                  Tab(text: 'Announcements'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SessionsTab(lab: lab),
                  PeopleTab(lab: lab),
                  const AnalyticsTab(),
                  AnnouncementsTab(lab: lab),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
