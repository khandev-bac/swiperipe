import 'package:flutter/material.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';

class SettingsScren extends StatelessWidget {
  const SettingsScren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Customcolors.primary,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Customcolors.customDarkBlue),
        backgroundColor: Customcolors.primary,
        title: Text("Settings", style: Customfonts.ScreensAppBar),
      ),
    );
  }
}
