import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_labs_mobile/providers/ppe_povider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logger = Logger();

class PPEDropdown extends ConsumerWidget {
  final List<String> selectedPPEIds;
  final Function(String ppeId, String ppeName) onAddPPE;
  final Function(String ppeId, String ppeName) onRemovePPE;

  const PPEDropdown({
    super.key,
    required this.selectedPPEIds,
    required this.onAddPPE,
    required this.onRemovePPE,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final chipBackgroundColor =
        isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface;
    final selectedColor =
        isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary;

    return ref.watch(ppeProvider).when(
          data: (ppeList) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required PPE',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ppeList.map((ppe) {
                    final isSelected =
                        selectedPPEIds.contains(ppe.id.toString());
                    return FilterChip(
                      label: Text(
                        ppe.name,
                        style: TextStyle(
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : textColor,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          logger.w("Selected PPE: ${ppe.name}");
                          onAddPPE(ppe.id.toString(), ppe.name);
                        } else {
                          onRemovePPE(ppe.id.toString(), ppe.name);
                        }
                      },
                      backgroundColor: chipBackgroundColor,
                      selectedColor: selectedColor,
                      checkmarkColor: isDark ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey[400]!,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              color:
                  isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
            ),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading PPE items: $error',
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        );
  }
}
