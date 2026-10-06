import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';

class GenericDetailPage extends StatefulWidget {
  final String title;
  final Map<dynamic, dynamic> data;

  const GenericDetailPage({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  State<GenericDetailPage> createState() => _GenericDetailPageState();
}

class _GenericDetailPageState extends State<GenericDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final String? orderValue = widget.data['Order Value']?.toString();

    final double keyWidth = screenWidth * 0.3;

    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: buildCommonAppBar(
        context: context,
        title: widget.title,
      ),
      body: Stack(
        children: [
          // 🔵 Blue Scrollbar with Themed Styling
          Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(ColorManager.blue),
                radius: const Radius.circular(8),
                thickness: MaterialStateProperty.all(6),
              ),
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, 16, 16, screenWidth * 0.25),
                child: Card(
                  color: ColorManager.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: widget.data.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: keyWidth,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Text(
                                ' : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value?.toString() ?? "-",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ColorManager.darkGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          //  Fixed Bottom Order Value Display
          if (orderValue != null)
            Positioned(
              left: 0, // full width
              right: 0,
              bottom: 0, // stick to bottom
              child: Container(
                width: double.infinity,
                color: ColorManager.white, // no border radius or card style
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Value:',
                      style: TextStyle(
                        color: ColorManager.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.s21,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderValue,
                      style: TextStyle(
                        color: ColorManager.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.s21,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
