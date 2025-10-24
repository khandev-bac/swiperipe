import 'package:flutter/material.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';

class StatesScren extends StatelessWidget {
  const StatesScren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Customcolors.primary,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Customcolors.customDarkBlue),
        centerTitle: true,
        backgroundColor: Customcolors.primary,
        title: Center(
          child: Text("SwipeRipe", style: Customfonts.ScreensAppBar),
        ),
      ),
    );
  }
}
