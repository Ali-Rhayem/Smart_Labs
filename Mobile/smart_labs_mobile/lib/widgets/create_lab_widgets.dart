import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:smart_labs_mobile/models/ppe_model.dart';

class PpeDropdown extends StatelessWidget {
  final List<String> selectedPPEs;
  final List<PPE> availablePPEs;
  final Function(List<String>) onPPEsChanged;

  const PpeDropdown({
    super.key,
    required this.selectedPPEs,
    required this.availablePPEs,
    required this.onPPEsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: MultiSelectContainer(
            items: availablePPEs
                .map((ppe) => MultiSelectCard(
                      value: ppe.id,
                      label: ppe.name,
                    ))
                .toList(),
            onChange: (selectedItems, selectedItem) {
              onPPEsChanged(selectedItems.cast<String>());
            },
          ),
        ),
      ],
    );
  }
}
