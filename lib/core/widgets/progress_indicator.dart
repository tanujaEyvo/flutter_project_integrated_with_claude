import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(ColorManager.darkBlue),
    );
  }
}

// class CustomProgressIndicator extends StatelessWidget {
//   const CustomProgressIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset(
//             ImageAssets.progressIndicator,
//             height: 80,
//             width: 80,
//             fit: BoxFit.contain,
//           ),
//           const SizedBox(height: 2),
//           Text(
//             'Please wait...',
//             style: TextStyle(
//               fontSize: FontSize.s14,
//               color: ColorManager.darkGrey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
