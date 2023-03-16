import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class AppEmojiPicker extends StatelessWidget {
  bool offstage;
  Function(Category?, Emoji) onEmojiSelected;
  Function onBackspacePressed;

  AppEmojiPicker(
      {super.key,
      required this.offstage,
      required this.onEmojiSelected,
      required this.onBackspacePressed});

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: offstage,
      // !emojiShowing,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
            onEmojiSelected: (category, Emoji emoji) {
              onEmojiSelected(category!, emoji);
            },
            onBackspacePressed: () => onBackspacePressed(),
            config: Config(
                columns: 7,
                // Issue: https://github.com/flutter/flutter/issues/28894
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                initCategory: Category.RECENT,
                bgColor: const Color(0xFFF2F2F2),
                indicatorColor: Colors.blue,
                iconColor: Colors.grey,
                iconColorSelected: Colors.blue,
                backspaceColor: Colors.blue,
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                showRecentsTab: true,
                recentsLimit: 28,
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL)),
      ),
    );
  }
}
