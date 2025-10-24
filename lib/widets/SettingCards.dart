import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String svg;
  final Color cardColor;
  final Color cardOpcolor;
  final Color iconColor;
  final VoidCallback onTap;
  const SettingCard({
    super.key,
    required this.title,
    required this.svg,
    required this.cardColor,
    required this.onTap,
    required this.iconColor,
    required this.titleColor,
    required this.cardOpcolor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [cardColor, cardOpcolor],
              begin: AlignmentGeometry.topLeft,
              end: AlignmentGeometry.bottomRight,
            ),
          ),
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Swiss",
                      color: titleColor,
                      fontSize: 20,
                    ),
                  ),
                  SvgPicture.asset(
                    svg,
                    width: 24,
                    height: 24,
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
