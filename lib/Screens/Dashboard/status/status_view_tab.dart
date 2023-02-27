import 'package:flutter/material.dart';

class StatusViewTab extends StatefulWidget {
  const StatusViewTab({super.key});

  @override
  State<StatusViewTab> createState() => _StatusViewTabState();
}

class _StatusViewTabState extends State<StatusViewTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("STatus view"),
    );
  }
}
