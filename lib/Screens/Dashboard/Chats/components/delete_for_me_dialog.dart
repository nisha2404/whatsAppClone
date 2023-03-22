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

class DeleteForMeDialog extends StatefulWidget {
  List<ChatModel> selectedChats;
  String chatRoomId;
  DeleteForMeDialog(
      {super.key, required this.selectedChats, required this.chatRoomId});

  @override
  State<DeleteForMeDialog> createState() => _DeleteForMeDialogState();
}

class _DeleteForMeDialogState extends State<DeleteForMeDialog> {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppTextButton(
                    onpress: () async {
                      await onDeletePress(
                          widget.chatRoomId, widget.selectedChats);
                    },
                    btnName: "Delete for me",
                    txtStyle: GetTextTheme.sf14_medium
                        .copyWith(color: AppColors.primaryColor)),
                AppServices.addWidth(5.w),
                AppTextButton(
                    onpress: () => AppServices.popView(context),
                    btnName: "Cancel",
                    txtStyle: GetTextTheme.sf14_medium
                        .copyWith(color: AppColors.primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  onDeletePress(String chatRoomId, List<ChatModel> selectedChats) async {
    final db = Provider.of<AppDataController>(context, listen: false);
    AppServices.popView(context);
    if (selectedChats.any((e) =>
        e.status == MessageStatus.deleteForMe ||
        e.status == MessageStatus.deleteForEveryone)) {
      final chats = selectedChats
          .where((e) =>
              e.status == MessageStatus.deleteForMe ||
              e.status == MessageStatus.deleteForEveryone)
          .toList();
      for (var chat in chats) {
        final path = database.ref("chatRoom/$chatRoomId/chats/${chat.msgId}");
        if (FirebaseController().isSender(chat)) {
          if (chat.status == MessageStatus.deleteByReceiver) {
            await path.update({"status": MessageStatus.permanentDelete.name});
            db.updateChatIsDelete(MessageStatus.permanentDelete, chat.msgId);
          } else {
            await path.update({"status": MessageStatus.deleteBySender.name});
            db.updateChatIsDelete(MessageStatus.deleteBySender, chat.msgId);
          }
        } else {
          if (chat.status == MessageStatus.deleteBySender) {
            await path.update({"status": MessageStatus.permanentDelete.name});
            db.updateChatIsDelete(MessageStatus.permanentDelete, chat.msgId);
          } else {
            await path.update({"status": MessageStatus.deleteByReceiver.name});
            db.updateChatIsDelete(MessageStatus.deleteByReceiver, chat.msgId);
          }
        }
      }
    } else {
      for (var chat in selectedChats) {
        final path = database.ref("chatRoom/$chatRoomId/chats/${chat.msgId}");
        await path.update({"status": MessageStatus.deleteForMe.name});
        db.updateChatIsDelete(MessageStatus.deleteForMe, chat.msgId);
      }
    }
  }
}
