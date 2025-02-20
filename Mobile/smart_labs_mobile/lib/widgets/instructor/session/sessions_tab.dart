import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/session_provider.dart';
import 'package:smart_labs_mobile/widgets/instructor/session/session_card.dart';

class SessionsTab extends ConsumerStatefulWidget {
  final Lab lab;

  const SessionsTab({super.key, required this.lab});

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab> {
  static const Color kNeonAccent = Color(0xFFFFFF00);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sessionsAsync = ref.watch(labSessionsProvider(widget.lab.labId));
    final updatedLab = ref.watch(labsProvider).whenData(
          (labs) => labs.firstWhere((l) => l.labId == widget.lab.labId),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      if (!updatedLab.value!.started) {
                        final response = await ref
                            .read(
                                labSessionsProvider(widget.lab.labId).notifier)
                            .startSession();
                        if (response['success']) {
                          ref
                              .read(labsProvider.notifier)
                              .updateLabStatus(widget.lab.labId, true);
                        }
                      } else {
                        final response = await ref
                            .read(
                                labSessionsProvider(widget.lab.labId).notifier)
                            .endSession();
                        if (response['success']) {
                          ref
                              .read(labsProvider.notifier)
                              .updateLabStatus(widget.lab.labId, false);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: updatedLab.value?.started ?? false
                  ? Colors.red
                  : (isDark ? kNeonAccent : theme.colorScheme.primary),
              foregroundColor: isDark
                  ? Colors.black
                  : (updatedLab.value?.started ?? false
                      ? Colors.white
                      : theme.colorScheme.onPrimary),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  )
                : Text(
                    updatedLab.value?.started ?? false
                        ? 'End Session'
                        : 'Start Session',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.black
                          : (updatedLab.value?.started ?? false
                              ? Colors.white
                              : theme.colorScheme.onPrimary),
                    ),
                  ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: isDark ? kNeonAccent : theme.colorScheme.primary,
            onRefresh: () async {
              // Fetch sessions
              await ref
                  .read(labSessionsProvider(widget.lab.labId).notifier)
                  .fetchSessions();

              // Fetch lab data
              final response = await ref
                  .read(labsProvider.notifier)
                  .fetchLabById(widget.lab.labId);
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
                    color:
                        theme.colorScheme.onBackground.withValues(alpha: 0.7),
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
                            color: theme.colorScheme.onBackground
                                .withValues(alpha: 0.7),
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
