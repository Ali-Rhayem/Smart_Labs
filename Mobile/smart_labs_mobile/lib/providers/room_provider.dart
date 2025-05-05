import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/services/api_service.dart';

class Room {
  final String id;
  final String name;

  Room({required this.id, required this.name});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']['timestamp'].toString(),
      name: json['name'],
    );
  }
}

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('/room');

  if (response['success'] != false) {
    final List<dynamic> data = response['data'];
    final result = data.map((json) => Room.fromJson(json)).toList();
    return result;
  }

  throw Exception('Failed to load rooms');
});
