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
    return ref.watch(ppeProvider).when(
      data: (ppeList) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required PPE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ppeList.map((ppe) {
                final isSelected = selectedPPEIds.contains(ppe.id.toString());
                return FilterChip(
                  label: Text(
                    ppe.name,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
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
                  backgroundColor: const Color(0xFF1C1C1C),
                  selectedColor: const Color(0xFFFFFF00),
                  checkmarkColor: Colors.black,
                  side: const BorderSide(color: Colors.white24),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading PPE items: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
