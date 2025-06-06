import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/widgets/instructor/analytics_tab.dart';
import 'package:smart_labs_mobile/widgets/instructor/announcement/announcements_tab.dart';
import 'package:smart_labs_mobile/widgets/instructor/lab_header.dart';
import 'package:smart_labs_mobile/widgets/instructor/people_tab.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/sessions_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/screens/instructor/edit_lab_screen.dart';
import 'package:collection/collection.dart';

var logger = Logger();

class InstructorLabDetailScreen extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const InstructorLabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final updatedLab = ref.watch(labsProvider).whenData(
          (labs) => labs.firstWhereOrNull((l) => l.labId == lab.labId),
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
      data: (currentLab) {
        if (currentLab == null) {
          // Lab was deleted, navigate back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
          return const SizedBox.shrink();
        }

        return DefaultTabController(
          length: 4,
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
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditLabScreen(lab: currentLab),
                      ),
                    );
                  },
                ),
              ],
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
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    labelColor:
                        isDark ? kNeonAccent : theme.colorScheme.primary,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor:
                        isDark ? kNeonAccent : theme.colorScheme.primary,
                    dividerColor: theme.dividerColor,
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
                      SessionsTab(lab: currentLab),
                      PeopleTab(lab: currentLab),
                      AnalyticsTab(labId: currentLab.labId),
                      AnnouncementsTab(lab: currentLab),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
