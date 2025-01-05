import 'package:flutter/material.dart';
import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/widgets/detail_row.dart';

class LabDetailScreen extends StatelessWidget {
  final Lab lab;
  const LabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(lab.labName),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildDetails(context),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailRow(title: 'Lab Code',value:  lab.labCode),
        DetailRow(title: 'Description',value: lab.description),
        DetailRow(title: 'Date',value: lab.date.toString()),
        DetailRow(title: 'Time',value:  '${lab.startTime} - ${lab.endTime}'),
        DetailRow(title: 'PPE Required',value:  lab.ppe),
        DetailRow(title: 'Instructors',value: lab.instructors.join(', ')),
        DetailRow(title: 'Students',value: lab.students.join(', ')),
        DetailRow(title: 'Report', value:  lab.report),
        DetailRow(title: 'Semester ID',value: lab.semesterId),
      ],
    );
  }

}
