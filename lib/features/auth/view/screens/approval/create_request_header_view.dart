import 'package:eyvo_v3/features/auth/view/screens/approval/base_header_form_view.dart';
import 'package:flutter/material.dart';

class CreateRequestHeaderView extends StatelessWidget {
  final int requestId;

  const CreateRequestHeaderView({Key? key, required this.requestId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseHeaderView(
      id: requestId,
      headerType: HeaderType.request,
      appBarTitle: "Request Header",
    );
  }
}
