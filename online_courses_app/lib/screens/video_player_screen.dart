import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/course.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Course course;

  const VideoPlayerScreen({super.key, required this.course});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'),
    )..initialize().then((_) {
        setState(() => isInitialized = true);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.course.title),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: isInitialized
                ? VideoPlayer(controller)
                : Center(child: CircularProgressIndicator()),
          ),
          if (isInitialized)
            VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: VideoProgressColors(playedColor: Colors.blue),
            ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10),
                  onPressed: () {
                    controller.seekTo(
                      controller.value.position - Duration(seconds: 10),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_10),
                  onPressed: () {
                    controller.seekTo(
                      controller.value.position + Duration(seconds: 10),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    'Course Lessons',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildLessonTile('Introduction', '5:30', true),
                  _buildLessonTile('Getting Started', '12:45', false),
                  _buildLessonTile('Advanced Topics', '18:20', false),
                  _buildLessonTile('Final Project', '30:00', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTile(String title, String duration, bool isPlaying) {
    return ListTile(
      leading: Icon(
        isPlaying ? Icons.play_circle : Icons.play_circle_outline,
        color: isPlaying ? Colors.blue : Colors.grey,
      ),
      title: Text(title),
      trailing: Text(duration),
      tileColor: isPlaying ? Colors.blue[50] : null,
      onTap: () {},
    );
  }
}
