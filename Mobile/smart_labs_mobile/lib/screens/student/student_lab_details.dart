import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/widgets/instructor/analytics_tab.dart';
import 'package:smart_labs_mobile/widgets/student/announcement/student_announcements_tab.dart';
import 'package:smart_labs_mobile/widgets/student/session/student_sessions_tab.dart';
import 'package:smart_labs_mobile/widgets/student/student_lab_header.dart';
import 'package:smart_labs_mobile/widgets/student/student_people_tab.dart';

class LabDetailScreen extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);
  const LabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatedLab = ref.watch(labsProvider).whenData(
          (labs) => labs.firstWhere((l) => l.labId == lab.labId),
        );

    return updatedLab.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: kNeonAccent),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error',
            style: const TextStyle(color: Colors.white70)),
      ),
      data: (currentLab) => DefaultTabController(
        length: 4, // We have 3 tabs
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            iconTheme: const IconThemeData(
              color: Colors.white, // back icon color
            ),
            title: const Text(
              'Lab Details',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabHeader(lab: currentLab),
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
                    PeopleTab(lab: currentLab),
                    const AnalyticsTab(),
                    StudentAnnouncementsTab(lab: currentLab),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
