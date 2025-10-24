import 'package:flutter/material.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';
import 'package:swiperipe/widets/SettingCards.dart';

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
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: "Swiss",
            fontSize: 20,
            color: Customcolors.customDarkBlue,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingCard(
            title: "Leave Review",
            svg: "assets/vectors/review.svg",
            cardColor: Customcolors.customBlue,
            onTap: () {},
            iconColor: Colors.white,
            titleColor: Colors.white,
          ),

          SettingCard(
            title: "My Stats",
            svg: "assets/vectors/state.svg",
            cardColor: Colors.pink,
            onTap: () {},
            iconColor: Colors.white,
            titleColor: Colors.white,
          ),
          SettingCard(
            title: "Contact Us",
            svg: "assets/vectors/cont.svg",
            cardColor: Colors.orange,
            onTap: () {},
            iconColor: Colors.white,
            titleColor: Colors.white,
          ),
          SettingCard(
            title: "Privacy Policy",
            svg: "assets/vectors/policy.svg",
            cardColor: Colors.lightBlue,
            onTap: () {},
            iconColor: Colors.white,
            titleColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
