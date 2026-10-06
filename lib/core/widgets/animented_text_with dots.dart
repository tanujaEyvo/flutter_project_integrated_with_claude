import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';

class AnimatedTextWithDots extends StatefulWidget {
  final String text;
  final String subtitle; // Optional subtitle

  const AnimatedTextWithDots({
    super.key,
    required this.text,
    required this.subtitle,
  });

  @override
  State<AnimatedTextWithDots> createState() => _AnimatedTextWithDotsState();
}

class _AnimatedTextWithDotsState extends State<AnimatedTextWithDots> {
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.text,
                    style: getBoldStyle(
                      color: ColorManager.black,
                      fontSize: FontSize.s20,
                    ),
                  ),
                  SizedBox(
                    width: 24, // Reserve space for "..."
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getDots(),
                        style: getBoldStyle(
                          color: ColorManager.black,
                          fontSize: FontSize.s20,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: getSemiBoldStyle(
              color: ColorManager.grey,
              fontSize: FontSize.s16,
            ),
          ),
        ],
      ),
    );
  }

  String _getDots() {
    switch (_dotCount) {
      case 0:
        return '';
      case 1:
        return '.';
      case 2:
        return '..';
      case 3:
        return '...';
      default:
        return '';
    }
  }
}
