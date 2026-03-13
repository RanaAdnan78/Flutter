import 'package:flutter/material.dart';
import '../models/course.dart';
import 'video_player_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[300],
                child: course.image.isNotEmpty
                    ? Image.network(course.image, fit: BoxFit.cover)
                    : Icon(Icons.play_circle, size: 80, color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${course.instructor}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                          Icons.star, '${course.rating}', Colors.amber),
                      SizedBox(width: 12),
                      _buildInfoChip(
                          Icons.people, '${course.students}', Colors.blue),
                      SizedBox(width: 12),
                      _buildInfoChip(
                          Icons.access_time, course.duration, Colors.green),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'About Course',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    course.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Course Content',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _buildLesson('Introduction to Course', '5:30'),
                  _buildLesson('Getting Started', '12:45'),
                  _buildLesson('Advanced Concepts', '18:20'),
                  _buildLesson('Practical Examples', '22:10'),
                  _buildLesson('Final Project', '30:00'),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price', style: TextStyle(color: Colors.grey[600])),
                Text(
                  'Rs. ${course.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(course: course),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Enroll Now', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildLesson(String title, String duration) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(duration, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
