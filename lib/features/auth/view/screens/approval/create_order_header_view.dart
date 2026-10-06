import 'package:eyvo_v3/features/auth/view/screens/approval/base_header_form_view.dart';
import 'package:flutter/material.dart';

class CreateOrderHeaderView extends StatelessWidget {
  final int orderId;

  const CreateOrderHeaderView({Key? key, required this.orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseHeaderView(
      id: orderId,
      headerType: HeaderType.order,
      appBarTitle: "Order Header",
    );
  }
}
