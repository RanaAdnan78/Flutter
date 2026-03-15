import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/courses/api/login.php';

  static Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Course> courses = [];
      for (var item in data['courses']) {
        courses.add(Course.fromJson(item));
      }
      return courses;
    }
    throw Exception('Failed to load courses');
  }

  static Future<Course> getCourseDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/course.php?id=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Course.fromJson(data);
    }
    throw Exception('Failed to load course');
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['user']);
    }
    throw Exception('Login failed');
  }
}
