import 'package:flutter/material.dart';

import '../helpers/style_sheet.dart';

class HelpPopUpMenuButton extends StatelessWidget {
  const HelpPopUpMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        position: PopupMenuPosition.under,
        itemBuilder: (context) => [
              PopupMenuItem(
                  height: 30,
                  child: const Text("Help", style: GetTextTheme.sf14_medium),
                  onTap: () => {})
            ]);
  }
}
