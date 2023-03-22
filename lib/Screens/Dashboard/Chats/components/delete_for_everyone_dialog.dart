// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:chatting_app/components/app_text_button.dart';
import 'package:chatting_app/helpers/base_getters.dart';
import 'package:chatting_app/helpers/style_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/app_data_controller.dart';
import '../../../../controllers/firebase_controller.dart';
import '../../../../models/app_models.dart';

class DeleteForEveryoneDialog extends StatefulWidget {
  List<ChatModel> selectedChats;
  String chatRoomId;
  DeleteForEveryoneDialog(
      {super.key, required this.selectedChats, required this.chatRoomId});

  @override
  State<DeleteForEveryoneDialog> createState() =>
      _DeleteForEveryoneDialogState();
}

class _DeleteForEveryoneDialogState extends State<DeleteForEveryoneDialog> {
  late MessageStatus status;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                  "Delete ${widget.selectedChats.length == 1 ? "message?" : "${widget.selectedChats.length} messages?"}",
                  style: GetTextTheme.sf16_medium
                      .copyWith(color: AppColors.grey150)),
            ),
            AppServices.addHeight(15.h),
            AppTextButton(
                onpress: () async {
                  setState(() => status = MessageStatus.deleteForEveryone);
                  await onDeletePress(
                      status, widget.chatRoomId, widget.selectedChats);
                },
                btnName: "Delete for everyone",
                txtStyle: GetTextTheme.sf14_medium
                    .copyWith(color: AppColors.primaryColor)),
            AppTextButton(
                onpress: () => {
                      setState(() => status = MessageStatus.deleteForMe),
                      onDeletePress(
                          status, widget.chatRoomId, widget.selectedChats)
                    },
                btnName: "Delete for me",
                txtStyle: GetTextTheme.sf14_medium
                    .copyWith(color: AppColors.primaryColor)),
            AppTextButton(
                onpress: () => AppServices.popView(context),
                btnName: "Cancel",
                txtStyle: GetTextTheme.sf14_medium
                    .copyWith(color: AppColors.primaryColor)),
          ],
        ),
      ),
    );
  }

  onDeletePress(MessageStatus status, String chatRoomId,
      List<ChatModel> selectedChats) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    AppServices.popView(context);
    for (var chat in selectedChats) {
      final path = database.ref("chatRoom/$chatRoomId/chats/${chat.msgId}");
      await path.update({"status": status.name});
      db.updateChatIsDelete(status, chat.msgId);
    }
  }
}
