import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/form_field_helper.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final TextEditingController _noteController = TextEditingController();
  List<bool> _isCardSelected = [true, false];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: buildCommonAppBar(
        context: context,
        title: 'Notes',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormFieldHelper.buildMultilineTextField(
              label: "Notes",
              controller: _noteController,
              // hintText: "Enter note",
              maxLines: 10,
              isRequired: true,
            ),
            const SizedBox(height: 30),
            Text(
              'File Privacy',
              style: getSemiBoldStyle(
                color: ColorManager.black,
                fontSize: FontSize.s14,
              ),
            ),
            const SizedBox(height: 8),
            FormFieldHelper.buildInfoCard(
              index: 0,
              icon: Icons.lock_outlined,
              title: "Private",
              subtitle: "Only you and invited members can see this file",
              isCardSelected: _isCardSelected,
              onTap: () {
                setState(() => _isCardSelected = [true, false]);
              },
            ),
            const SizedBox(height: 12),
            FormFieldHelper.buildInfoCard(
              index: 1,
              icon: Icons.public,
              title: "Public",
              subtitle: "Anyone with the link can view this file \n",
              isCardSelected: _isCardSelected,
              onTap: () {
                setState(() => _isCardSelected = [false, true]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
