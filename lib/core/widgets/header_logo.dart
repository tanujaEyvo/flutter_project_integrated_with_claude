import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:flutter/material.dart';

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(screenWidth * 0.5, 55.0),
            bottomRight: Radius.elliptical(screenWidth * 0.5, 55.0),
          ),
          image: const DecorationImage(
            image: AssetImage(ImageAssets.roundBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Image.asset(
              ImageAssets.splashIcon,
              width: 120,
              height: 90,
            ),
          ),
        ),
      ),
    );
  }
}
