import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final String crop;
  const SplashScreen({required this.crop});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  final List<String> videoPaths = ["assets/images/video_1.mp4"];
  int _currentVideoIndex = 0;
  void initState() {
    super.initState();
    if (mounted) {
      _initializeVideo();
    }
    Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.pushReplacementNamed(
        context,
        '/procedure',
        arguments: widget.crop,
      );
    });
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(videoPaths[_currentVideoIndex])
      ..initialize()
          .then((_) {
            setState(() {});
            _controller.play();
            _controller.setLooping(false);
            _controller.addListener(() {
              if (_controller.value.position >= _controller.value.duration &&
                  !_controller.value.isPlaying) {
                _changeVideo();
              }
            });
          })
          .catchError((error) {
            print("Error initializing video: $error");
          });
  }

  void _changeVideo() {
    _currentVideoIndex = (_currentVideoIndex + 1) % videoPaths.length;
    _controller.dispose();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: Hero(
              tag: 'videotag',
              child:
                  _controller.value.isInitialized
                      ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                      : Center(child: CircularProgressIndicator()),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.crop,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
