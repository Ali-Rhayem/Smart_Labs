import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final updatedLab = ref.watch(labsProvider).whenData(
          (labs) => labs.firstWhere((l) => l.labId == lab.labId),
        );

    return updatedLab.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: isDark ? kNeonAccent : theme.colorScheme.primary,
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: TextStyle(
            color: theme.colorScheme.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ),
      data: (currentLab) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor:
                isDark ? const Color(0xFF121212) : theme.colorScheme.surface,
            iconTheme: IconThemeData(
              color: theme.colorScheme.onSurface,
            ),
            title: Text(
              'Lab Details',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor:
              isDark ? const Color(0xFF121212) : theme.colorScheme.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabHeader(lab: currentLab),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1C)
                      : theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: TabBar(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelColor: isDark ? kNeonAccent : theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor:
                      isDark ? kNeonAccent : theme.colorScheme.primary,
                  dividerColor: theme.dividerColor,
                  tabs: const [
                    Tab(text: 'Sessions'),
                    Tab(text: 'People'),
                    Tab(text: 'Announcements'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SessionsTab(lab: lab),
                    PeopleTab(lab: currentLab),
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
