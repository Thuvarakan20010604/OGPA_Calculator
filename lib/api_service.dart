import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android Emulator use 10.0.2.2
  // For Web/Desktop use http://localhost:3000
  static const String baseUrl = 'http://localhost:3000';

  // ---------------- GET SUBJECTS ----------------
  static Future<List<dynamic>> getSubjects(String studentName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/subjects/$studentName'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch subjects');
    }
  }

  // ---------------- ADD SUBJECT ----------------
  static Future<Map<String, dynamic>> addSubject(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add subject');
    }
  }

  // ---------------- UPDATE SUBJECT ----------------
  static Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update subject');
    }
  }

  // ---------------- DELETE SUBJECT ----------------
  static Future<void> deleteSubject(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/subjects/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete subject');
    }
  }
}
