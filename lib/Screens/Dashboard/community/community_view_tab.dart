import 'package:flutter/material.dart';

class CommunityViewTab extends StatefulWidget {
  const CommunityViewTab({super.key});

  @override
  State<CommunityViewTab> createState() => _CommunityViewTabState();
}

class _CommunityViewTabState extends State<CommunityViewTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("Community view"),
    );
  }
}
