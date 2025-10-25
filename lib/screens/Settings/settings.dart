import 'package:flutter/material.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/widets/SettingCards.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SettingCard(
              title: "Subscribe",
              svg: "assets/vectors/review.svg",
              cardColor: Color(0xFF842A3B),
              onTap: () {},
              iconColor: Colors.white,
              titleColor: Colors.white,
              cardOpcolor: Color(0xFFA3485A),
            ),
            const SizedBox(height: 10),
            SettingCard(
              title: "Leave Review",
              svg: "assets/vectors/heart.svg",
              cardColor: Customcolors.customBlue,
              onTap: () {},
              iconColor: Colors.white,
              titleColor: Colors.white,
              cardOpcolor: Color(0xFF696FC7),
            ),
            const SizedBox(height: 10),
            SettingCard(
              title: "My Stats",
              svg: "assets/vectors/state.svg",
              cardColor: Colors.pink,
              onTap: () {},
              iconColor: Colors.white,
              titleColor: Colors.white,
              cardOpcolor: Color(0xFFF75270),
            ),
            const SizedBox(height: 10),
            SettingCard(
              title: "Feature Request",
              svg: "assets/vectors/request.svg",
              cardColor: Colors.cyan,
              onTap: () {},
              iconColor: Colors.white,
              titleColor: Colors.white,
              cardOpcolor: Colors.cyanAccent,
            ),
            const SizedBox(height: 10),
            SettingCard(
              title: "Contact Us",
              svg: "assets/vectors/cont.svg",
              cardColor: Colors.orange,
              onTap: () {},
              iconColor: Colors.white,
              titleColor: Colors.white,
              cardOpcolor: Color(0xFFE2A16F),
            ),
            const SizedBox(height: 10),
            SettingCard(
              title: "Privacy Policy",
              svg: "assets/vectors/policy.svg",
              cardColor: Colors.lightBlue,
              onTap: () async {
                const url =
                    'https://www.freeprivacypolicy.com/live/e2cf112e-b862-4a0b-9185-57b04a98f27f';
                final Uri uri = Uri.parse(url);

                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication, // <--- Important!
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not open the link")),
                  );
                }
              },
              iconColor: Colors.white,
              titleColor: Colors.white,
              cardOpcolor: Color(0xFF80A1BA),
            ),
          ],
        ),
      ),
    );
  }
}
