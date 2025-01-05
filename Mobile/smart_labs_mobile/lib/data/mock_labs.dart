import 'package:smart_labs_mobile/models/lab_model.dart';
import 'package:smart_labs_mobile/models/session_model.dart';

final List<Lab> mockLabs = [
  Lab(
    labId: '1',
    labCode: 'CHEM101',
    labName: 'Intro to Chemistry',
    description: 'Lab safety & fundamentals',
    ppe: 'Gloves, Goggles',
    instructors: ['Dr. Smith', 'Dr. Johnson'],
    students: ['John Doe', 'Jane Smith'],
    date: DateTime(2023, 5, 10),
    startTime: '09:00 AM',
    endTime: '11:00 AM',
    report: 'N/A',
    semesterId: 'SEM2023A',
    sessions: [
      Session(
        id: 'S1',
        labId: '1',
        date: DateTime(2023, 5, 10),
        startTime: '09:00 AM',
        endTime: '10:00 AM',
        output: [
          StudentRecord(
            studentId: 'ST101',
            studentName: 'John Doe',
            attendance: true,
            ppe: true,
          ),
          StudentRecord(
            studentId: 'ST102',
            studentName: 'Jane Smith',
            attendance: false,
            ppe: false,
          ),
        ],
        report: 'Initial safety briefing and lab orientation.',
      ),
      Session(
        id: 'S2',
        labId: '1',
        date: DateTime(2023, 5, 10),
        startTime: '10:00 AM',
        endTime: '11:00 AM',
        output: [
          StudentRecord(
            studentId: 'ST101',
            studentName: 'John Doe',
            attendance: true,
            ppe: true,
          ),
          StudentRecord(
            studentId: 'ST102',
            studentName: 'Jane Smith',
            attendance: true,
            ppe: true,
          ),
        ],
        report: 'Simple acid-base experiment.',
      ),
    ],
  ),
  Lab(
    labId: '2',
    labCode: 'BIO202',
    labName: 'Advanced Biology',
    description: 'Dissection & microscope usage',
    ppe: 'Lab Coat, Gloves, Goggles',
    instructors: ['Dr. Brown'],
    students: ['Alice Green', 'Bob Grey'],
    date: DateTime(2023, 5, 12),
    startTime: '01:00 PM',
    endTime: '03:30 PM',
    report: 'N/A',
    semesterId: 'SEM2023A',
    sessions: [
      Session(
        id: 'S1',
        labId: '2',
        date: DateTime(2023, 5, 12),
        startTime: '01:00 PM',
        endTime: '02:00 PM',
        output: [
          StudentRecord(
            studentId: 'ST201',
            studentName: 'Alice Green',
            attendance: true,
            ppe: true,
          ),
          StudentRecord(
            studentId: 'ST202',
            studentName: 'Bob Grey',
            attendance: true,
            ppe: false,
          ),
        ],
        report: 'Microscope usage and sample prep.',
      ),
      Session(
        id: 'S2',
        labId: '2',
        date: DateTime(2023, 5, 12),
        startTime: '02:00 PM',
        endTime: '03:30 PM',
        output: [
          StudentRecord(
            studentId: 'ST201',
            studentName: 'Alice Green',
            attendance: true,
            ppe: true,
          ),
          StudentRecord(
            studentId: 'ST202',
            studentName: 'Bob Grey',
            attendance: true,
            ppe: true,
          ),
        ],
        report: 'Frog dissection experiment.',
      ),
    ],
  ),
];
