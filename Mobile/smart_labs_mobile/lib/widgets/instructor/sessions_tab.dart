import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/session_provider.dart';
import 'package:smart_labs_mobile/widgets/session_card.dart';

class SessionsTab extends ConsumerWidget {
  final Lab lab;
  static const Color kNeonAccent = Color(0xFFFFFF00);

  const SessionsTab({super.key, required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(labSessionsProvider(lab.labId));
    final updatedLab = ref.watch(labsProvider).whenData(
          (labs) => labs.firstWhere((l) => l.labId == lab.labId),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              try {
                if (!updatedLab.value!.started) {
                  await ref
                      .read(labSessionsProvider(lab.labId).notifier)
                      .startSession();
                } else {
                  await ref
                      .read(labSessionsProvider(lab.labId).notifier)
                      .endSession();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  updatedLab.value?.started ?? false ? Colors.red : kNeonAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              updatedLab.value?.started ?? false
                  ? 'End Session'
                  : 'Start Session',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: kNeonAccent,
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
              loading: () => const Center(
                child: CircularProgressIndicator(color: kNeonAccent),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.white70),
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
                            color: Colors.white.withValues(alpha: 0.7),
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
