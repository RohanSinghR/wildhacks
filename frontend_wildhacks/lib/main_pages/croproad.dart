import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CropRoadPage extends StatefulWidget {
  @override
  _CropRoadPageState createState() => _CropRoadPageState();
}

class _CropRoadPageState extends State<CropRoadPage>
    with SingleTickerProviderStateMixin {
  List<String> steps = [
    "Prepare the land by plowing and leveling.",
    "Select high-quality rice seeds.",
    "Sowing seeds in nursery beds.",
    "Transplant seedlings to main field.",
    "Ensure proper irrigation and fertilization.",
  ];

  List<String> descriptions = [
    "Clear the field of debris and weeds. Plow the soil to loosen it and break up clods. Level the field to ensure even water distribution.",
    "Choose certified seeds with high germination rates. Consider disease-resistant varieties suitable for your local climate and soil conditions.",
    "Prepare raised nursery beds with well-drained soil. Sow pre-soaked seeds evenly and maintain proper moisture levels.",
    "When seedlings reach 4-5 leaves stage, carefully uproot and transplant them to the main field in rows with proper spacing.",
    "Maintain appropriate water levels throughout growth stages. Apply fertilizers at recommended intervals and monitor for nutrient deficiencies.",
  ];

  List<bool> completed = [false, false, false, false, false];
  late AnimationController _animationController;
  late Animation<double> _flowAnimation;
  late VideoPlayerController _controller;
  final List<String> videoPaths = ["assets/images/video_1.mp4"];
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _animationController.repeat(); // Only play once

    _flowAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    if (mounted) {
      _initializeVideo();
    }
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
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void toggleCompletion(int index) {
    setState(() {
      completed[index] = !completed[index];
    });
  }

  void showStepDescription(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Step ${index + 1}: ${steps[index]}"),
            content: Text(descriptions[index]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
                style: TextButton.styleFrom(foregroundColor: Color(0xFF2E7D32)),
              ),
              ElevatedButton(
                onPressed: () {
                  toggleCompletion(index);
                  Navigator.pop(context);
                },
                child: Text(
                  completed[index] ? "Mark as Incomplete" : "Mark as Complete",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = completed.where((item) => item).length;
    double progress = completedCount / steps.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(197, 76, 175, 79),
        title: const Text(
          "Cultivation Roadmap",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black45,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.0),
          child: Container(
            height: 6.0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.3),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width * progress,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: _buildZigZagSteps(), // Removed FadeTransition here
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/alerts');
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Progress Summary"),
                  content: Text(
                    "You have completed $completedCount out of ${steps.length} steps.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ],
                ),
          );
        },
        label: Text("View Progress", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.analytics, color: Colors.white),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildZigZagSteps() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index % 2 == 0) {
            final stepIndex = index ~/ 2;
            final isLeft = stepIndex % 2 == 0;

            return Row(
              mainAxisAlignment:
                  isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (!isLeft) Spacer(),
                InkWell(
                  onTap: () => showStepDescription(stepIndex),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color:
                              completed[stepIndex]
                                  ? Color(0xFF2E7D32).withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                      border:
                          completed[stepIndex]
                              ? Border.all(color: Color(0xFF2E7D32), width: 2)
                              : null,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  completed[stepIndex]
                                      ? Color(0xFF2E7D32)
                                      : Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${stepIndex + 1}",
                                style: TextStyle(
                                  color:
                                      completed[stepIndex]
                                          ? Colors.white
                                          : Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              steps[stepIndex],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: completed[stepIndex],
                            onChanged: (value) => toggleCompletion(stepIndex),
                            activeColor: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLeft) Spacer(),
              ],
            );
          } else {
            final fromIndex = index ~/ 2;
            final toIndex = fromIndex + 1;
            final isCompleted = completed[fromIndex] && completed[toIndex];

            return Container(
              height: 50,
              child: AnimatedBuilder(
                animation: _flowAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(double.infinity, 50),
                    painter: FlowingLinePainter(
                      isLeft: fromIndex % 2 == 0,
                      animationValue: _flowAnimation.value,
                      isCompleted: isCompleted,
                    ),
                  );
                },
              ),
            );
          }
        }),
      ),
    );
  }
}

// Custom painter for the flowing line effect
class FlowingLinePainter extends CustomPainter {
  final bool isLeft;
  final double animationValue;
  final bool isCompleted;

  FlowingLinePainter({
    required this.isLeft,
    required this.animationValue,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
        Paint()
          ..color =
              isCompleted
                  ? Color(0xFF2E7D32).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final Paint flowPaint =
        Paint()
          ..color =
              isCompleted ? Color(0xFF2E7D32) : Colors.grey.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final Path path = Path();

    if (isLeft) {
      path.moveTo(size.width * 0.3, 0);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.7,
        size.height,
      );
    } else {
      path.moveTo(size.width * 0.7, 0);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.3,
        size.height,
      );
    }

    canvas.drawPath(path, linePaint);

    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      final double pathLength = pathMetric.length;

      final double start = (animationValue - 0.2) * pathLength;
      final double end = animationValue * pathLength;

      if (start > 0 && start < pathLength) {
        final Path extractPath = pathMetric.extractPath(
          start < 0 ? 0 : start,
          end > pathLength ? pathLength : end,
        );
        canvas.drawPath(extractPath, flowPaint);
      }

      if (end > 0 && end < pathLength) {
        final Tangent? tangent = pathMetric.getTangentForOffset(end);
        if (tangent != null) {
          canvas.drawCircle(
            tangent.position,
            4,
            Paint()..color = isCompleted ? Color(0xFF2E7D32) : Colors.grey,
          );
        }
      }
    }

    final Offset arrowPosition =
        isLeft
            ? Offset(size.width * 0.7, size.height)
            : Offset(size.width * 0.3, size.height);

    canvas.drawCircle(
      arrowPosition,
      6,
      Paint()
        ..color =
            isCompleted ? Color(0xFF2E7D32) : Colors.grey.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(FlowingLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isCompleted != isCompleted;
  }
}
