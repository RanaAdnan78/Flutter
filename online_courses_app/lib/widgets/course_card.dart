import 'package:flutter/material.dart';
import '../models/course.dart';
import '../screens/course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: course.image.isNotEmpty
                  ? Image.network(
                      course.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image, size: 50),
                    )
                  : Icon(Icons.school, size: 50),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${course.instructor}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text('${course.rating}'),
                      SizedBox(width: 16),
                      Icon(Icons.people, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${course.students} students'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${course.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Chip(
                        label: Text(course.level),
                        backgroundColor: Colors.blue[50],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
