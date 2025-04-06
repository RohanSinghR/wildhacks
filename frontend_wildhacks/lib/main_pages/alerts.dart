import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:video_player/video_player.dart';

class AlertPage extends StatefulWidget {
  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage>
    with SingleTickerProviderStateMixin {
  // Sample JSON data - in a real app, this would come from an API or service
  final String sampleJson = '''
  {
    "alerts": [
      {
        "type": "fire",
        "detected": true,
        "severity": "high",
        "location": "North Field",
        "timestamp": "2025-04-06T08:30:00"
      },
      {
        "type": "pest",
        "detected": true,
        "pestType": "Rice Stem Borer",
        "severity": "medium",
        "location": "East Field",
        "timestamp": "2025-04-05T14:20:00"
      },
      {
        "type": "pest",
        "detected": false,
        "lastCheck": "2025-04-06T07:00:00"
      },
      {
        "type": "fire",
        "detected": false,
        "lastCheck": "2025-04-06T08:00:00"
      }
    ]
  }
  ''';

  late Map<String, dynamic> alertData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool hasFireAlert = false;
  bool hasPestAlert = false;
  late VideoPlayerController _controller;
  final List<String> videoPaths = ["assets/images/video_1.mp4"];
  int _currentVideoIndex = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Parse JSON data
    alertData = jsonDecode(sampleJson);
    checkAlerts();
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

  void checkAlerts() {
    for (var alert in alertData['alerts']) {
      if (alert['detected'] == true) {
        if (alert['type'] == 'fire') {
          hasFireAlert = true;
          _showFireNotification(alert);
        } else if (alert['type'] == 'pest') {
          hasPestAlert = true;
          _showPestNotification(alert);
        }
      }
    }
  }

  void _showFireNotification(Map<String, dynamic> alert) {
    // In a real app, this would trigger a system notification
    // For this demo, we'll show a SnackBar when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URGENT: Fire detected in ${alert['location']}!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              _showAlertDetails(alert);
            },
          ),
        ),
      );
    });
  }

  void _showPestNotification(Map<String, dynamic> alert) {
    // Similar to fire notification but with different styling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alert: ${alert['pestType']} detected in ${alert['location']}',
          ),
          backgroundColor: Colors.amber[700],
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              _showAlertDetails(alert);
            },
          ),
        ),
      );
    });
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              alert['type'] == 'fire'
                  ? 'Fire Alert Details'
                  : 'Pest Alert Details',
              style: TextStyle(
                color: alert['type'] == 'fire' ? Colors.red : Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAlertDetailRow(
                  'Type',
                  alert['type'].toString().toUpperCase(),
                ),
                _buildAlertDetailRow('Location', alert['location']),
                _buildAlertDetailRow(
                  'Severity',
                  alert['severity'].toString().toUpperCase(),
                ),
                if (alert['type'] == 'pest')
                  _buildAlertDetailRow('Pest Type', alert['pestType']),
                _buildAlertDetailRow(
                  'Detected At',
                  _formatTimestamp(alert['timestamp']),
                ),
                SizedBox(height: 16),
                Text(
                  'Recommended Action:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  alert['type'] == 'fire'
                      ? 'Evacuate the area immediately and contact emergency services.'
                      : 'Inspect the affected area and consider applying appropriate treatment.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CLOSE'),
              ),
              ElevatedButton(
                onPressed: () {
                  // In a real app, this would mark the alert as acknowledged
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      alert['type'] == 'fire' ? Colors.red : Colors.amber[700],
                  foregroundColor: Colors.white,
                ),
                child: Text('ACKNOWLEDGE'),
              ),
            ],
          ),
    );
  }

  Widget _buildAlertDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Field Alerts'),
        backgroundColor: Color.fromARGB(176, 46, 125, 50),
        actions: [
          if (hasFireAlert || hasPestAlert)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 24 + (_animation.value * 4),
                      ),
                      Positioned(
                        right: 0,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: hasFireAlert ? Colors.red : Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            (hasFireAlert && hasPestAlert) ? '2' : '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
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
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildAlertSection('Fire Status', 'fire'),
                  SizedBox(height: 24),
                  _buildAlertSection('Pest Status', 'pest'),
                  SizedBox(height: 24),
                  _buildRecentAlertsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSection(String title, String alertType) {
    bool hasActiveAlert = alertData['alerts'].any(
      (alert) => alert['type'] == alertType && alert['detected'] == true,
    );

    return Container(
      width: MediaQuery.of(context).size.width / 3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                hasActiveAlert
                    ? (alertType == 'fire' ? Colors.red : Colors.amber)
                    : Colors.green,
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    alertType == 'fire'
                        ? Icons.local_fire_department
                        : Icons.bug_report,
                    color:
                        hasActiveAlert
                            ? (alertType == 'fire'
                                ? Colors.red
                                : Colors.amber[700] ?? Colors.amber)
                            : Colors.green,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  if (hasActiveAlert)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (alertType == 'fire'
                                    ? Colors.red
                                    : Colors.amber[700] ?? Colors.amber)
                                .withOpacity(0.6 + (_animation.value * 0.4)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'CLEAR',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              _buildAlertDetails(alertType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertDetails(String alertType) {
    var activeAlerts =
        alertData['alerts']
            .where(
              (alert) =>
                  alert['type'] == alertType && alert['detected'] == true,
            )
            .toList();

    if (activeAlerts.isEmpty) {
      var lastCheck =
          alertData['alerts'].firstWhere(
            (alert) => alert['type'] == alertType && alert['detected'] == false,
            orElse: () => {'lastCheck': 'Unknown'},
          )['lastCheck'];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No ${alertType == 'fire' ? 'fire' : 'pest'} detected',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Last checked: ${lastCheck != 'Unknown' ? _formatTimestamp(lastCheck) : 'Unknown'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            activeAlerts.map<Widget>((alert) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  alertType == 'fire'
                      ? 'Fire detected in ${alert['location']}'
                      : '${alert['pestType']} detected in ${alert['location']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        alertType == 'fire'
                            ? Colors.red[700]
                            : Colors.amber[800],
                  ),
                ),
                subtitle: Text(
                  'Severity: ${alert['severity'].toUpperCase()} • ${_formatTimestamp(alert['timestamp'])}',
                ),
                trailing: ElevatedButton(
                  onPressed: () => _showAlertDetails(alert),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        alertType == 'fire' ? Colors.red : Colors.amber[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Details'),
                ),
              );
            }).toList(),
      );
    }
  }

  Widget _buildRecentAlertsList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ...alertData['alerts'].where((alert) => alert['detected'] == true).map<
              Widget
            >((alert) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      alert['type'] == 'fire'
                          ? Colors.red.withOpacity(0.2)
                          : Colors.amber.withOpacity(0.2),
                  child: Icon(
                    alert['type'] == 'fire'
                        ? Icons.local_fire_department
                        : Icons.bug_report,
                    color:
                        alert['type'] == 'fire'
                            ? Colors.red
                            : Colors.amber[700],
                  ),
                ),
                title: Text(
                  alert['type'] == 'fire'
                      ? 'Fire Alert'
                      : 'Pest Alert: ${alert['pestType']}',
                ),
                subtitle: Text(
                  '${alert['location']} • ${_formatTimestamp(alert['timestamp'])}',
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAlertDetails(alert),
              );
            }).toList(),
            if (alertData['alerts']
                .where((alert) => alert['detected'] == true)
                .isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No recent alerts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
