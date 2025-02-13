import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/session_provider.dart';
import 'package:smart_labs_mobile/widgets/student/session/session_card.dart';

class SessionsTab extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const SessionsTab({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sessionsAsync = ref.watch(labSessionsProvider(lab.labId));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: isDark ? kNeonAccent : theme.colorScheme.primary,
            onRefresh: () async {
              // Fetch sessions
              await ref
                  .read(labSessionsProvider(lab.labId).notifier)
                  .fetchSessions();

              // Fetch lab data
              final response =
                  await ref.read(labsProvider.notifier).fetchLabById(lab.labId);
              if (!response['success']) {
                throw Exception(
                    response['message'] ?? 'Failed to refresh lab data');
              }
            },
            child: sessionsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: isDark ? kNeonAccent : theme.colorScheme.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Center(
                        child: Text(
                          'No sessions available.',
                          style: TextStyle(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return SessionCard(session: session);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
