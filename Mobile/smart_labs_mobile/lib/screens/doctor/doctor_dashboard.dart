import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for doctor's labs
    const totalLabs = 5;
    const avgAttendance = 78;
    const highestPerformingLab = "Lab A"; 
    const lowestPerformingLab = "Lab C";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              child: ListTile(
                leading: Icon(Icons.science_outlined,
                    size: 40, color: Colors.orange),
                title: Text('Total Labs'),
                subtitle: Text('You are supervising $totalLabs labs currently'),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading:
                     Icon(Icons.bar_chart, size: 40, color: Colors.purple),
                title:  Text('Average Attendance'),
                subtitle:
                    Text('Average attendance across labs is $avgAttendance%'),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.trending_up,
                    size: 40, color: Colors.green),
                title: Text('Highest Performing Lab'),
                subtitle: Text(
                    '$highestPerformingLab has the best attendance and participation'),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.trending_down,
                    size: 40, color: Colors.red),
                title: Text('Lowest Performing Lab'),
                subtitle:
                    Text('$lowestPerformingLab could use some improvements'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'More detailed analytics coming soon!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
