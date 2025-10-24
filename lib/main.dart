import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Customcolors.primary,
        appBar: AppBar(
          title: Text("SwipeRipe", style: Customfonts.swiss),
          backgroundColor: Customcolors.primary,
          actions: [
            // First icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  print("State tapped");
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Customcolors.customDarkBlue,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/vectors/state.svg",
                    width: 24,
                    height: 24,
                    color: Customcolors.primary,
                  ),
                ),
              ),
            ),

            // Second icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  print("Delete tapped");
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Customcolors.customDarkBlue,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/vectors/settings.svg",
                    width: 24,
                    height: 24,
                    color: Customcolors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(child: Text("Hello")),
      ),
    );
  }
}
