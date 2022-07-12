import 'package:flutter/material.dart';
import 'package:rotating_carousel/rotating_carousel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(
        child: Scaffold(
          body: RotatingCarousel(
            panels: [
              Image.asset(
                "assets/images/person.jpeg",
                fit: BoxFit.fill,
              ),
              Image.asset(
                "assets/images/she.jpeg",
                fit: BoxFit.fill,
              ),
              Image.asset(
                "assets/images/person.jpeg",
                fit: BoxFit.fill,
              ),
              // Image.asset(
              //   "assets/images/she.jpeg",
              //   fit: BoxFit.fill,
              // ),
              // Image.asset(
              //   "assets/images/person.jpeg",
              //   fit: BoxFit.fill,
              // ),
              // Image.asset(
              //   "assets/images/she.jpeg",
              //   fit: BoxFit.fill,
              // )
            ],
            height: 150,
            width: 300,
          ),
        ),
      ),
    );
  }
}
