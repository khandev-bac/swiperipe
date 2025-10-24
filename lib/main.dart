import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';
import 'package:swiperipe/screens/Settings/settings.dart';
import 'package:swiperipe/screens/StatesScreen/StateScreen.dart';

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
            Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();

                      // Use the context from inside the Scaffold
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatesScren(),
                        ),
                      );
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
                );
              },
            ),

            // Second icon
            Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      print("Delete tapped");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScren(),
                        ),
                      );
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
                );
              },
            ),
          ],
        ),
        body: Center(child: Text("Hello")),
      ),
    );
  }
}
