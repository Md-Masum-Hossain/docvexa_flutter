import 'package:flutter/material.dart';

import 'status_views.dart';

class DesignPlaceholderPage extends StatelessWidget {
  const DesignPlaceholderPage({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppEmptyView(title: title, message: message, icon: icon),
    );
  }
}
