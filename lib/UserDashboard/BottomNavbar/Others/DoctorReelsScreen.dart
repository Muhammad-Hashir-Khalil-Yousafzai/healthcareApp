import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DoctorReelsScreen extends StatefulWidget {
  const DoctorReelsScreen({super.key});

  @override
  State<DoctorReelsScreen> createState() => _DoctorReelsScreenState();
}

class _DoctorReelsScreenState extends State<DoctorReelsScreen> {
  final List<Map<String, String>> reels = [
    {
      'video': 'assets/videos/Thanos.mp4',
      'doctor': 'Dr. Strange',
      'specialty': 'Magician',
      'caption': 'Fanmade MCU part',
    },
    {
      'video': 'assets/videos/Songs.mp4',
      'doctor': 'Dr. Zain',
      'specialty': 'Nephrologist',
      'caption': 'Our Sweet Home',
    },
    {
      'video': 'assets/videos/breathing_exercise.mp4',
      'doctor': 'Dr. Aiman Asif',
      'specialty': 'Pulmonologist',
      'caption': 'Breathing exercises for asthma patients',
    },
  ];

  late PageController _pageController;
  final List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    for (var reel in reels) {
      final controller = VideoPlayerController.asset(reel['video']!)
        ..initialize().then((_) => setState(() {}))
        ..setLooping(true)
        ..play();
      _videoControllers.add(controller);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final reel = reels[index];
          final controller = _videoControllers[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              controller.value.isInitialized
                  ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
                  : Center(child: CircularProgressIndicator(color: Colors.deepPurple)),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),

              Positioned(
                left: 16,
                bottom: 80,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reel['doctor']!,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(reel['specialty']!,
                        style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(reel['caption']!,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),

              Positioned(
                right: 16,
                bottom: 80,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
                    ),
                    SizedBox(height: 12),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
