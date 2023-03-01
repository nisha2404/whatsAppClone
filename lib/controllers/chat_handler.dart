import 'package:chatting_app/controllers/app_data_controller.dart';
import 'package:chatting_app/models/app_models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHandler {
  onMsgSend(BuildContext context, DatabaseEvent event) {
    final db = Provider.of<AppDataController>(context, listen: false);
    db.addChat(ChatModel.fromChat(event.snapshot.value as Map<Object?, Object?>,
        event.snapshot.key.toString()));
  }
}
