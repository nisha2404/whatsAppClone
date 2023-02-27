import 'package:flutter/material.dart';

class CallViewsTab extends StatefulWidget {
  const CallViewsTab({super.key});

  @override
  State<CallViewsTab> createState() => _CallViewsTabState();
}

class _CallViewsTabState extends State<CallViewsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("Call view"),
    );
  }
}
