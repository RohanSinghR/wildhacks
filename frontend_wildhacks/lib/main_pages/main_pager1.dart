import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

class MainPager1 extends StatefulWidget {
  @override
  _MainPager1State createState() => _MainPager1State();
}

class _MainPager1State extends State<MainPager1> {
  final List<String> videoPaths = ["assets/images/video_1.mp4"];
  int _currentVideoIndex = 0;
  late VideoPlayerController _controller;
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadExistingCSVData();
  }

  // Load any existing data (for persistence between sessions)
  Future<void> _loadExistingCSVData() async {
    if (kIsWeb) {
      // For web, we'll check local storage
      final storedData = html.window.localStorage['devices_csv'];
      if (storedData != null) {
        try {
          final List<dynamic> jsonData = jsonDecode(storedData);
          csvData = List<List<dynamic>>.from(
            jsonData.map((row) => List<dynamic>.from(row)),
          );
          print('✅ Loaded ${csvData.length} records from local storage');
        } catch (e) {
          print('❌ Error loading data from local storage: $e');
          csvData = [];
        }
      }
    } else {
      // For mobile/desktop platforms
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/devices.csv');

        if (await file.exists()) {
          final content = await file.readAsString();
          csvData = const CsvToListConverter().convert(content);
          print('✅ Loaded ${csvData.length} records from file');
        }
      } catch (e) {
        print('❌ Error loading existing CSV: $e');
      }
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
    _controller.dispose();
    super.dispose();
  }

  // Cross-platform method to save device data
  Future<void> saveToCSV(String deviceId) async {
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Device ID cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add new device to our in-memory data
    csvData.add([deviceId, DateTime.now().toIso8601String()]);

    if (kIsWeb) {
      // For web platform, use localStorage
      try {
        // Convert the CSV data to JSON string for storage
        final jsonString = jsonEncode(csvData);
        html.window.localStorage['devices_csv'] = jsonString;

        // Also offer CSV download in web
        final csvString = const ListToCsvConverter().convert(csvData);
        final bytes = utf8.encode(csvString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", "devices.csv")
              ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();

        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print('✅ Device ID "$deviceId" saved and available for download');
      } catch (e) {
        print('❌ Error saving CSV in web: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving data: $e"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      // For mobile/desktop platforms
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/devices.csv');

        final csvContent = const ListToCsvConverter().convert(csvData);
        await file.writeAsString(csvContent);
        print('✅ Device ID "$deviceId" saved at: ${file.absolute.path}');
      } catch (e) {
        print('❌ Error saving CSV: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving data: $e"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Your device '$deviceId' has been successfully registered!",
        ),
        backgroundColor: const Color.fromARGB(146, 105, 240, 175),
      ),
    );
  }

  void showAddDeviceDialog(BuildContext context) {
    final TextEditingController deviceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Add Device", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceController,
                decoration: InputDecoration(
                  hintText: "Enter Device ID",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              if (csvData.isNotEmpty)
                Container(
                  height: 100,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Registered Devices:",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...csvData
                            .map(
                              (row) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                child: Text(
                                  "• ${row[0]}",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                if (deviceController.text.trim().isNotEmpty) {
                  saveToCSV(deviceController.text.trim());
                  Navigator.of(context).pop();
                } else {
                  // Show error for empty input
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter a device ID"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  // Dialog to view saved devices
  void showSavedDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Saved Devices", style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child:
                csvData.isEmpty
                    ? Center(
                      child: Text(
                        "No devices registered yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      itemCount: csvData.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            csvData[index][0].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle:
                              csvData[index].length > 1
                                  ? Text(
                                    "Added: ${csvData[index][1]}",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  )
                                  : null,
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                csvData.removeAt(index);
                              });

                              // Update storage
                              if (kIsWeb) {
                                html.window.localStorage['devices_csv'] =
                                    jsonEncode(csvData);
                              } else {
                                getApplicationDocumentsDirectory().then((
                                  directory,
                                ) {
                                  final file = io.File(
                                    '${directory.path}/devices.csv',
                                  );
                                  final csvContent = const ListToCsvConverter()
                                      .convert(csvData);
                                  file.writeAsString(csvContent);
                                });
                              }

                              // Refresh dialog
                              Navigator.of(context).pop();
                              showSavedDevicesDialog(context);
                            },
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close", style: TextStyle(color: Colors.greenAccent)),
            ),
            if (csvData.isNotEmpty && kIsWeb)
              TextButton(
                onPressed: () {
                  final csvString = const ListToCsvConverter().convert(csvData);
                  final bytes = utf8.encode(csvString);
                  final blob = html.Blob([bytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor =
                      html.AnchorElement(href: url)
                        ..setAttribute("download", "devices.csv")
                        ..style.display = 'none';

                  html.document.body?.children.add(anchor);
                  anchor.click();

                  html.document.body?.children.remove(anchor);
                  html.Url.revokeObjectUrl(url);
                },
                child: Text(
                  "Download CSV",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(165, 0, 0, 0),
        // actions: [
        //   Container(
        //     height: mediaQueryData.size.height / 20,
        //     width: mediaQueryData.size.width / 10,
        //     child: ElevatedButton.icon(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: const Color.fromARGB(133, 105, 240, 175),
        //         foregroundColor: Colors.white,
        //       ),
        //       onPressed: () {},
        //       icon: Icon(Icons.agriculture_outlined),
        //       label: Text('Soil Detection'),
        //     ),
        //   ),
        //   Container(
        //     height: mediaQueryData.size.height / 20,
        //     width: mediaQueryData.size.width / 10,
        //     child: ElevatedButton.icon(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: const Color.fromARGB(133, 105, 240, 175),
        //         foregroundColor: Colors.white,
        //       ),
        //       onPressed: () {},
        //       icon: Icon(Icons.agriculture_outlined),
        //       label: Text('Procedure'),
        //     ),
        //   ),
        //   Container(
        //     height: mediaQueryData.size.height / 20,
        //     width: mediaQueryData.size.width / 10,
        //     child: ElevatedButton.icon(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: const Color.fromARGB(133, 105, 240, 175),
        //         foregroundColor: Colors.white,
        //       ),
        //       onPressed: () => showSavedDevicesDialog(context),
        //       icon: Icon(Icons.devices),
        //       label: Text('View Devices'),
        //     ),
        //   ),
        // ],
      ),
      extendBodyBehindAppBar: true,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: mediaQueryData.size.height / 10),
                Text(
                  "Welcome to Picrop",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 6,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOut),
                SizedBox(height: mediaQueryData.size.height / 10),
                Container(
                  height: mediaQueryData.size.height / 3,
                  width: mediaQueryData.size.width / 3,
                  child: Image.asset('assets/images/rpi.png'),
                ),
                SizedBox(height: mediaQueryData.size.height / 10),
                Container(
                  height: mediaQueryData.size.height / 20,
                  width: mediaQueryData.size.width / 5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(133, 105, 240, 175),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => showAddDeviceDialog(context),
                    child: Text("Add Device"),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  height: mediaQueryData.size.height / 20,
                  width: mediaQueryData.size.width / 5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(133, 105, 240, 175),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/soil'); //for timebeing
                    },
                    child: Text("Next"),
                  ),
                ),

                SizedBox(height: 20),

                TextButton.icon(
                  onPressed: () => showSavedDevicesDialog(context),
                  icon: Icon(Icons.list, color: Colors.white70),
                  label: Text(
                    "View Registered Devices (${csvData.length})",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
