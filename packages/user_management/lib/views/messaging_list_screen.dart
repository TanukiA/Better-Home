import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/controllers/messaging_controller.dart';
import 'package:user_management/models/message.dart';
import 'package:user_management/views/message_users_container.dart';
import 'package:intl/intl.dart';

class MessagingListScreen extends StatefulWidget {
  const MessagingListScreen(
      {Key? key, required this.controller, required this.userType})
      : super(key: key);
  final MessagingController controller;
  final String userType;
  final bool isLoading = false;

  @override
  StateMVC<MessagingListScreen> createState() => _MessagingListScreenState();
}

class _MessagingListScreenState extends StateMVC<MessagingListScreen> {
  late List<List<Message>> allMessages;
  List<Message> messageUserList = [];
  bool isLoading = true;

  @override
  initState() {
    setMessagingList();
    super.initState();
  }

  void setMessagingList() async {
    allMessages = await widget.controller
        .retrieveAllUserMessages(widget.userType, context);
    print("allMessages: $allMessages");
    if (allMessages.isNotEmpty) {
      for (int i = 0; i < allMessages.length; i++) {
        List<Message> messages = allMessages[i];
        Message latestMessage = messages.last;
        messageUserList.add(latestMessage);
      }
      print("messageUserList: $messageUserList");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Messaging',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        leading: const BackButton(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(
          size: 40,
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              color: Color.fromARGB(255, 51, 119, 54),
            ))
          : allMessages.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'No message record yet',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        itemCount: messageUserList.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 16),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return MessageUsersContainer(
                            name: messageUserList[index].senderName!,
                            messageText: messageUserList[index].messageText!,
                            time: messageUserList[index].dateTimeStr!,
                            isMessageRead:
                                (index == 0 || index == 3) ? true : false,
                            allMessages: allMessages,
                            controller: widget.controller,
                            userType: widget.userType,
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
