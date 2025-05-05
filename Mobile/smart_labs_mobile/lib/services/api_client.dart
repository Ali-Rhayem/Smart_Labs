// import 'package:http/http.dart' as http;
// import '../utils/secure_storage.dart';
// import 'dart:convert';

// class ApiClient {
//   final String baseUrl = 'YOUR_API_BASE_URL';
//   final SecureStorage _secureStorage = SecureStorage();

//   Future<http.Response> authenticatedRequest(
//     String endpoint,
//     {String method = 'GET', Map<String, dynamic>? body}
//   ) async {
//     final token = await _secureStorage.getToken();
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };

//     switch (method) {
//       case 'GET':
//         return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
//       case 'POST':
//         return await http.post(
//           Uri.parse('$baseUrl$endpoint'),
//           headers: headers,
//           body: json.encode(body),
//         );
//       default:
//         throw Exception('Unsupported HTTP method');
//     }
//   }
// } 