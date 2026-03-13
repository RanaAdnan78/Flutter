class Course {
  final int id;
  final String title;
  final String instructor;
  final String description;
  final String image;
  final double price;
  final double rating;
  final int students;
  final int lessons;
  final String duration;
  final String level;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.students,
    required this.lessons,
    required this.duration,
    required this.level,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      instructor: json['instructor'],
      description: json['description'],
      image: json['image'],
      price: double.parse(json['price'].toString()),
      rating: double.parse(json['rating'].toString()),
      students: json['students'],
      lessons: json['lessons'],
      duration: json['duration'],
      level: json['level'],
    );
  }
}
