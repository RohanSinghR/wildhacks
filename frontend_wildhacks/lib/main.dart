import 'package:flutter/material.dart';
import 'package:frontend_wildhacks/Home/landingpage1.dart';
import 'package:frontend_wildhacks/main_pages/alerts.dart';
import 'package:frontend_wildhacks/main_pages/main_pager1.dart';
import 'package:frontend_wildhacks/main_pages/procedure.dart';
import 'package:frontend_wildhacks/main_pages/soil.dart';
import 'package:frontend_wildhacks/main_pages/croproad.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyAgri());
}

class MyAgri extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => Landingpage1(),
        '/home': (context) => MainPager1(),
        '/soil': (context) => SoilPage(),
        '/procedure': (context) => ProcedurePage(),
        '/croproad': (context) => CropRoadPage(),
        '/alerts': (context) => AlertPage(),
      },
    );
  }
}
