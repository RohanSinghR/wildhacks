import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../globals.dart' as globals;
import 'dart:convert'; // Make sure this is present for json.decode
// Ensure this import points to your actual home page file if it exists
// import 'package:frontend_wildhacks/main_pages/main_pager1.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Landingpage1 extends StatefulWidget {
  @override
  State<Landingpage1> createState() => _Landingpage1State();
}

class _Landingpage1State extends State<Landingpage1> {
  List<double> _opacityLevels = List.filled(8, 0.0);
  List<bool> _flipTrigger = List.filled(8, false);
  Timer? _animationTimer;

  // --- Controllers moved to state variables ---
  // Controllers for Signup Dialog
  late TextEditingController _signupUsernameController;
  late TextEditingController _signupDimensionsController;
  late TextEditingController _signupLocationController;
  late TextEditingController _signupPasswordController;
  late TextEditingController _signupConfirmPasswordController;

  // Controllers for Login Dialog
  late TextEditingController _loginUsernameController;
  late TextEditingController _loginPasswordController;

  final List<String> _images = [
    'https://media.istockphoto.com/id/1401722160/photo/sunny-plantation-with-growing-soya.jpg?s=612x612&w=0&k=20&c=r_Y3aJ-f-4Oye0qU_TBKvqGUS1BymFHdx3ryPkyyV0w=',
    'https://thumbs.dreamstime.com/b/agriculture-vegetable-field-landscape-view-freshly-growing-84090367.jpg',
    'https://www.columbiatribune.com/gcdn/authoring/2015/08/04/NCDT/ghows-MO-9a879756-0531-43fa-a37b-75a5dc9e01f5-b3bc0399.jpeg?width=660&height=438&fit=crop&format=pjpg&auto=webp',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHPg-4dHp6Gec6G7ve8HstzRH0PkkF6VueSQ&s',
    'https://media.istockphoto.com/id/1901542091/photo/tractor-spraying-soybean-crops-field.jpg?s=612x612&w=0&k=20&c=38X2xY_f3DSOGGg94LuhYYhbGlizYyg18lCsimMTbuU=',
    'https://media.istockphoto.com/id/543212762/photo/tractor-cultivating-field-at-spring.jpg?s=612x612&w=0&k=20&c=uJDy7MECNZeHDKfUrLNeQuT7A1IqQe89lmLREhjIJYU=',
    'https://thumbs.dreamstime.com/b/agriculture-vegetable-field-landscape-view-freshly-growing-84090367.jpg',
    'https://eu-images.contentstack.com/v3/assets/bltdd43779342bd9107/bltb56dca46258ba2be/63909af83403b511fcd6be60/agrculture-issues-1018763972.jpg?width=1280&auto=webp&quality=95&format=jpg&disable=upscale',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _signupUsernameController = TextEditingController();
    _signupDimensionsController = TextEditingController();
    _signupLocationController = TextEditingController();
    _signupPasswordController = TextEditingController();
    _signupConfirmPasswordController = TextEditingController();
    _loginUsernameController = TextEditingController();
    _loginPasswordController = TextEditingController();

    _startAnimations();
  }

  void _startAnimations() {
    if (!mounted) return;
    setState(() {
      _opacityLevels = List.filled(8, 0.0);
      _flipTrigger = List.filled(8, false);
    });
    for (int i = 0; i < _images.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) {
          setState(() {
            _opacityLevels[i] = 1.0;
          });
          Future.delayed(Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _flipTrigger[i] = true;
              });
            }
          });
        }
      });
    }
    Future.delayed(Duration(milliseconds: 200 * _images.length + 2000), () {
      for (int i = 0; i < _images.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i), () {
          if (mounted) {
            setState(() {
              _opacityLevels[i] = 0.0;
              _flipTrigger[i] = false;
            });
          }
        });
      }
      _animationTimer = Timer(
        Duration(milliseconds: 150 * _images.length + 500),
        () {
          if (mounted) {
            _startAnimations();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    // Dispose controllers
    _signupUsernameController.dispose();
    _signupDimensionsController.dispose();
    _signupLocationController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  // Reusable text field widget (kept as in original)
  Widget textfielder(
    String helperText,
    TextEditingController control,
    String hinttxt,
    String label, {
    bool obscureText = false, // Added parameter for password obscurity
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        child: TextFormField(
          obscureText: obscureText,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          controller: control,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: EdgeInsets.all(10),
            hintStyle: TextStyle(color: Colors.white),
            labelStyle: TextStyle(color: Colors.white70),
            hintText: hinttxt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            helperText: helperText,
            helperStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // --- Login Logic ---

  // ... inside your _Landingpage1State class ...

  Future<void> _handleLogin() async {
    // Check if the widget is still mounted before proceeding
    if (!mounted) return;

    final String username = _loginUsernameController.text;
    final String password = _loginPasswordController.text;

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both username and password.'),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    // Prepare data for the request body
    final Map<String, String> data = {
      "username": username,
      "password": password,
    };

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(
          'https://nwh-kfyjj5scr-nishchals-projects-80d9f9a5.vercel.app/login',
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data), // Encode the data map to a JSON string
      );

      // Check if the widget is still mounted after the await call
      if (!mounted) return;

      // Check if the login was successful (status code 200)
      if (response.statusCode == 200) {
        // ---vvv--- START: Code to process successful response & store User ID ---vvv---
        try {
          // Parse the JSON response body
          final responseData = json.decode(response.body);

          // ---!!! IMPORTANT: CHANGE 'user_id' IF YOUR BACKEND USES A DIFFERENT KEY !!!---
          // Attempt to extract the user ID using the key 'user_id'
          final userIdFromServer = responseData['id'];
          // ---!!!---------------------------------------------------------------------!!!---

          // Check if the user ID was found in the response
          if (userIdFromServer != null) {
            // Store the ID (converted to string) in the global variable
            globals.currentUserId = userIdFromServer.toString();
            // --- THIS IS THE PRINT STATEMENT YOU ASKED FOR ---
            print(
              'Login successful. User ID stored: ${globals.currentUserId}',
            ); // Print the stored ID to the debug console
            // --- END OF PRINT STATEMENT ---
          } else {
            // Handle the case where login was successful but the ID key was missing
            print(
              "Login successful, but 'user_id' not found in response body.",
            );
            globals.currentUserId = null; // Ensure global variable is null
          }
        } catch (e) {
          // Handle errors during JSON parsing
          print("Error parsing login response JSON: $e");
          globals.currentUserId =
              null; // Ensure global variable is null on error
          // Show a specific snackbar for this parsing error case
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login successful, but failed to process server response.',
              ),
              backgroundColor: Colors.orange[900],
            ),
          );
          // Optional: Decide if you should stop execution here if the ID is critical
          // return;
        }
        // ---^^^--- END: Code to store User ID ---^^^---

        // --- Actions after successful login (and ID storage attempt) ---
        Navigator.pop(context); // Close the login dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Successful!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );

        // Navigate to the home page route
        Navigator.pushReplacementNamed(
          context,
          '/home', // Make sure '/home' route is defined in your MaterialApp
        );
      } else {
        // --- Handle login failure (status code other than 200) ---
        String errorMessage = 'Login failed. Please check credentials.';
        try {
          // Try to get a more specific error message from the response body
          final responseBody = json.decode(response.body);
          errorMessage = responseBody['error'] ?? errorMessage;
        } catch (_) {
          // Ignore if the response body isn't valid JSON or doesn't have 'error' key
        }
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // --- Handle network errors or other exceptions during the request ---
      if (!mounted) return; // Check mount status again after potential error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong during login. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Login Network/Request Error: $e"); // Log the actual error
    }
  }

  // --- Signup Logic ---
  Future<void> _handleSignup() async {
    if (!mounted) return;

    // Collect the data from the controllers
    String username = _signupUsernameController.text; // Use state controller
    String dimensions =
        _signupDimensionsController.text; // Use state controller
    String location = _signupLocationController.text; // Use state controller
    String password = _signupPasswordController.text; // Use state controller
    String confirmPassword =
        _signupConfirmPasswordController.text; // Use state controller

    // Basic Validation
    if (username.isEmpty ||
        dimensions.isEmpty ||
        location.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields.'),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    // Prepare the request body
    Map<String, String> data = {
      "username": username,
      "land_area": dimensions,
      "land_location": location,
      "password": password,
    };

    try {
      // Send a POST request
      final response = await http.post(
        Uri.parse(
          'https://nwh-kfyjj5scr-nishchals-projects-80d9f9a5.vercel.app/signup',
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If the server returns a successful response, show success message
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have successfully signed up!!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.blue[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
        // Optionally clear fields after successful signup
        _signupUsernameController.clear();
        _signupDimensionsController.clear();
        _signupLocationController.clear();
        _signupPasswordController.clear();
        _signupConfirmPasswordController.clear();
      } else {
        // If the server returns an error, show error message
        String errorMessage = 'Signup failed. Please try again.';
        try {
          final responseBody = json.decode(response.body);
          errorMessage = responseBody['error'] ?? errorMessage;
        } catch (_) {
          // Ignore if response body is not valid JSON
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Handle any errors that might occur during the request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong! Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Signup Error: $e");
    }
  }

  bool hover = false;
  @override
  Widget build(BuildContext context) {
    // const glowColor = Color.fromARGB(255, 52, 52, 78); // Original variable, unused
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    // Original button style setup from user code
    final ButtonStyle originalElevatedButtonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 3, color: Color.fromRGBO(149, 182, 78, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      padding: EdgeInsets.all(8),
      shadowColor: Colors.black,
      backgroundColor: Color.fromRGBO(44, 54, 22, 1),
      foregroundColor: Colors.white,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color.fromRGBO(107, 129, 59, 1),
                    spreadRadius: 1,
                  ),
                ],
              ),
              height: mediaQueryData.size.height / 10, // Original height
              width: mediaQueryData.size.width / 15, // Original width
              child: ElevatedButton(
                onPressed: () {
                  _loginUsernameController.clear();
                  _loginPasswordController.clear();

                  showDialog(
                    context: context,
                    builder:
                        (context) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: AlertDialog(
                                  backgroundColor: Color.fromRGBO(
                                    44,
                                    54,
                                    22,
                                    1,
                                  ),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                  content: Row(
                                    // Original Row structure
                                    children: [
                                      Container(
                                        // Original Image Container
                                        width:
                                            MediaQuery.of(context).size.width /
                                            4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                            2.5,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.asset(
                                          'assets/images/farmer.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              textfielder(
                                                "Username",
                                                _loginUsernameController,
                                                "username",
                                                "Enter your username",
                                              ),
                                              SizedBox(height: 12),
                                              textfielder(
                                                "Password",
                                                _loginPasswordController, // Use state controller
                                                "password",
                                                "Enter your password",
                                                obscureText:
                                                    true, // Hide password
                                              ),
                                              SizedBox(height: 24),
                                              Listener(
                                                onPointerHover: (event) {
                                                  setState(() {
                                                    hover = !hover;
                                                  });
                                                },
                                                child: GestureDetector(
                                                  onTap: _handleLogin,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 40,
                                                          vertical: 14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          hover
                                                              ? Color.fromRGBO(
                                                                84,
                                                                104,
                                                                40,
                                                                1,
                                                              )
                                                              : Color.fromRGBO(
                                                                44,
                                                                54,
                                                                22,
                                                                1,
                                                              ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                      boxShadow: [
                                                        // Original Shadows
                                                        BoxShadow(
                                                          color: Color.fromRGBO(
                                                            149,
                                                            179,
                                                            85,
                                                            1,
                                                          ),
                                                          blurRadius: 20,
                                                          spreadRadius: 1,
                                                          offset: Offset(0, 0),
                                                        ),
                                                        BoxShadow(
                                                          color: Color.fromRGBO(
                                                            161,
                                                            192,
                                                            94,
                                                            1,
                                                          ),
                                                          blurRadius: 30,
                                                          spreadRadius: 2,
                                                          offset: Offset(0, 0),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      'Log In',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
                child: Text(
                  // Original Button Text
                  "Log In",
                  style: GoogleFonts.akatab(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: originalElevatedButtonStyle, // Apply original style
              ),
            ),
          ),
          SizedBox(width: mediaQueryData.size.width / 150), // Original SizedBox
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color.fromRGBO(44, 54, 22, 1),
                    spreadRadius: 1,
                  ),
                ],
              ),
              height: mediaQueryData.size.height / 10,
              width: mediaQueryData.size.width / 15,
              child: ElevatedButton(
                onPressed: () {
                  _signupUsernameController.clear();
                  _signupDimensionsController.clear();
                  _signupLocationController.clear();
                  _signupPasswordController.clear();
                  _signupConfirmPasswordController.clear();

                  showDialog(
                    context: context,
                    builder:
                        (context) => BackdropFilter(
                          // Original structure
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: AlertDialog(
                                  backgroundColor: Color.fromRGBO(
                                    44,
                                    54,
                                    22,
                                    1,
                                  ),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                  content: Row(
                                    children: [
                                      Container(
                                        // Original Image Container
                                        width:
                                            MediaQuery.of(context).size.width /
                                            4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                            2.5,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.asset(
                                          'assets/images/farmer.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              // --- Signup Fields ---
                                              textfielder(
                                                "Username",
                                                _signupUsernameController, // Use state controller
                                                "username",
                                                "Enter your username",
                                              ),
                                              SizedBox(height: 12),
                                              textfielder(
                                                "Dimensions",
                                                _signupDimensionsController, // Use state controller
                                                "dimension",
                                                "Enter the dimensions of your land (in acres)",
                                              ),
                                              SizedBox(height: 12),
                                              textfielder(
                                                "location",
                                                _signupLocationController, // Use state controller
                                                "location",
                                                "Enter your field location",
                                              ),
                                              SizedBox(height: 12),
                                              textfielder(
                                                // Use reusable widget for password
                                                "password",
                                                _signupPasswordController, // Use state controller
                                                "password",
                                                "Enter your password",
                                                obscureText: true,
                                              ),
                                              SizedBox(height: 12),
                                              textfielder(
                                                // Use reusable widget for confirm password
                                                "Confirm password",
                                                _signupConfirmPasswordController, // Use state controller
                                                "Confirm password",
                                                "Re-enter password",
                                                obscureText: true,
                                              ),
                                              SizedBox(height: 24),
                                              // --- Save (Sign Up) Button (Original Structure) ---
                                              GestureDetector(
                                                // Original GestureDetector
                                                onTap:
                                                    _handleSignup, // Call signup handler
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 40,
                                                    vertical: 14,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        hover
                                                            ? Color.fromRGBO(
                                                              84,
                                                              104,
                                                              40,
                                                              1,
                                                            )
                                                            : Color.fromRGBO(
                                                              44,
                                                              54,
                                                              22,
                                                              1,
                                                            ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                    boxShadow: [
                                                      // Original Shadows
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                          149,
                                                          179,
                                                          85,
                                                          1,
                                                        ),
                                                        blurRadius: 20,
                                                        spreadRadius: 1,
                                                        offset: Offset(0, 0),
                                                      ),
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                          161,
                                                          192,
                                                          94,
                                                          1,
                                                        ),
                                                        blurRadius: 30,
                                                        spreadRadius: 2,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    'Sign Up',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                },
                child: Text(
                  // Original Button Text
                  "Sign Up",
                  style: GoogleFonts.akatab(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: originalElevatedButtonStyle, // Apply original style
              ),
            ),
          ),
          SizedBox(
            width: mediaQueryData.size.width / 50,
          ), // Added SizedBox from previous version for spacing consistency
        ],
      ),

      // --- Main Body Content (Original Structure) ---
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(44, 54, 22, 1),
              Colors.black,
              Color.fromRGBO(44, 54, 22, 1),
            ],
            // Assuming default gradient direction was intended
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SingleChildScrollView(
          // Added SingleChildScrollView to prevent overflow as content is tall
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: kToolbarHeight + 40), // Keep space below app bar
              Text(
                // Original Text Style
                'Picrop',
                style: GoogleFonts.abel(
                  fontSize: mediaQueryData.size.height / 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(
                begin: 1,
                end: 0,
                curve: Curves.easeOut,
              ), // Original Animation
              Padding(
                // Wrap AnimatedTextKit in Padding for spacing
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: AnimatedTextKit(
                  // Original AnimatedTextKit
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TyperAnimatedText(
                      textAlign: TextAlign.center,
                      textStyle: GoogleFonts.abel(
                        fontSize:
                            mediaQueryData.size.height /
                            20, // Kept original size reference
                        color: Colors.white,
                      ),
                      'You personal agriculture assistant that will look after everything for you', // Original Text
                      speed: Duration(
                        milliseconds: 50,
                      ), // Adjusted speed slightly for readability
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Added spacing before images
              Row(
                // Original Row Structure
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (index) {
                  // Original top margin calculation
                  double topMargin = switch (index) {
                    0 || 7 => 100.0,
                    1 || 6 => 200.0,
                    2 || 5 => 300.0,
                    3 || 4 => 400.0,
                    _ => 0.0,
                  };

                  Widget imageContainer = AnimatedOpacity(
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    opacity: _opacityLevels[index],
                    child: Container(
                      // Original Image Container
                      margin: EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: topMargin,
                      ),
                      height: mediaQueryData.size.height / 3, // Original height
                      width: mediaQueryData.size.width / 10, // Original width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        // Original ClipRRect
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(_images[index], fit: BoxFit.cover),
                      ),
                    ),
                  );

                  return _flipTrigger[index] // Original Flip Animation Trigger
                      ? imageContainer.animate().flip(
                        direction: Axis.horizontal,
                        duration: Duration(milliseconds: 600),
                      )
                      : imageContainer;
                }),
              ),
              SizedBox(height: 50), // Add space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
