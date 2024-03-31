import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static String id = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  var db = FirebaseFirestore.instance;

  int calculateDifferenceInMinutes(DateTime time1, DateTime time2) {
    Duration difference = time2.difference(time1);
    int differenceInMinutes = difference.inMinutes.abs();
    return differenceInMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              }),
        ],
        title: const Text('⚡️Chat'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildStreamBuilder(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5.0, 3, 0, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        controller: controller,
                        onChanged: (value) {
                          //Do something with the user input.
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    Timestamp timestamp = Timestamp.fromDate(now);
                    final city = <String, dynamic>{
                      "sender":
                          FirebaseAuth.instance.currentUser?.email ?? "hello",
                      "text": controller.text,
                      'timestamp': timestamp,
                    };

                    db
                        .collection("user")
                        .doc()
                        .set(city)
                        .onError((e, _) => print("Error writing document: $e"));

                    // Get documents sorted by timestamp in descending order

                    controller.clear();
                  },
                  child: const Text(
                    'Send',
                    style: kSendButtonTextStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('user')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          List<MessageBubble> messagesBubbles = [];
          for (var index = 0; index < snapshot.data!.docs.length; index++) {
            int positon = 0;

            var message = snapshot.data!.docs[index];
            bool isYou =
                message['sender'] == FirebaseAuth.instance.currentUser?.email
                    ? true
                    : false;


            var nextMessageTime =
                snapshot.data!.docs[index + 1]['timestamp'].toDate();
            var currentMessageTime =
                snapshot.data!.docs[index]['timestamp'].toDate();
            var previousMessageTime =
                snapshot.data!.docs[index - 1]['timestamp'].toDate();
            var nextMessageUserName = snapshot.data!.docs[index + 1]['sender'];

            var previousMessageUserName =
                snapshot.data!.docs[index - 1]['sender'];
            var currentUserName = FirebaseAuth.instance.currentUser?.email;

            if (isYou) {
              if (index == 0) {
                if (calculateDifferenceInMinutes(
                            nextMessageTime, currentMessageTime) <
                        5 &&
                    nextMessageUserName == currentUserName) {
                  positon = 1;
                } else if (nextMessageUserName == currentUserName &&
                        calculateDifferenceInMinutes(
                                nextMessageTime, currentMessageTime) >=
                            5 ||
                    nextMessageUserName != currentUserName) {
                  positon = 0;
                }
              } else if (index == snapshot.data!.docs.length - 1) {
                if (calculateDifferenceInMinutes(
                            previousMessageTime, currentMessageTime) <
                        5 &&
                    previousMessageUserName == currentUserName) {
                  positon = 6;
                } else if (previousMessageUserName == currentUserName &&
                        calculateDifferenceInMinutes(
                                previousMessageTime, currentMessageTime) >=
                            5 ||
                    previousMessageUserName != currentUserName) {
                  positon = 0;
                }
              } else {
                if (previousMessageUserName != currentUserName &&
                        nextMessageUserName == currentUserName &&
                        calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                            5 ||
                    calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5 &&
                        calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                            5) {
                  positon = 1;
                } else if (previousMessageUserName == currentUserName &&
                    nextMessageUserName == currentUserName &&
                    calculateDifferenceInMinutes(
                            previousMessageTime, currentMessageTime) <
                        5 &&
                    calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                        5) {
                  positon = 2;
                } else if (previousMessageUserName == currentUserName &&
                        nextMessageUserName != currentUserName &&
                        calculateDifferenceInMinutes(
                                previousMessageTime, currentMessageTime) <
                            5 ||
                    calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) >= 5 &&
                        calculateDifferenceInMinutes(
                                previousMessageTime, currentMessageTime) <
                            5) {
                  positon = 3;
                } else if (previousMessageUserName != currentUserName &&
                        nextMessageUserName != currentUserName ||
                    previousMessageUserName == currentUserName &&
                        nextMessageUserName == currentUserName &&
                        calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) >= 5 &&
                        calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5) {
                  positon = 0;
                }
              }
            } else {
              if (index == 0) {
                if (calculateDifferenceInMinutes(
                            nextMessageTime, currentMessageTime) <
                        5 &&
                    nextMessageUserName != currentUserName) {
                  positon = 1;
                } else if (nextMessageUserName != currentUserName &&
                        calculateDifferenceInMinutes(
                                nextMessageTime, currentMessageTime) >=
                            5 ||
                    nextMessageUserName == currentUserName) {
                  positon = 0;
                }
              } else if (index == snapshot.data!.docs.length - 1) {
                if (calculateDifferenceInMinutes(
                            previousMessageTime, currentMessageTime) <
                        5 &&
                    previousMessageUserName != currentUserName) {
                  positon = 6;
                } else if (previousMessageUserName != currentUserName &&
                        calculateDifferenceInMinutes(
                                previousMessageTime, currentMessageTime) >=
                            5 ||
                    previousMessageUserName == currentUserName) {
                  positon = 0;
                }
              } else {
                if (previousMessageUserName == currentUserName &&
                        nextMessageUserName != currentUserName &&
                        calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                            5 ||
                    calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5 &&
                        calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                            5) {
                  positon = 4;
                } else if (previousMessageUserName != currentUserName &&
                    nextMessageUserName != currentUserName &&
                    calculateDifferenceInMinutes(
                            previousMessageTime, currentMessageTime) <
                        5 &&
                    calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                        5) {
                  positon = 5;
                } else if (previousMessageUserName != currentUserName &&
                        nextMessageUserName == currentUserName ||
                    calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) >= 5 &&
                        calculateDifferenceInMinutes(
                                previousMessageTime, currentMessageTime) <
                            5) {
                  positon = 6;
                } else if (previousMessageUserName != currentUserName &&
                        nextMessageUserName != currentUserName ||
                    previousMessageUserName == currentUserName &&
                        nextMessageUserName == currentUserName &&
                        calculateDifferenceInMinutes(
                                nextMessageTime, currentMessageTime) >=
                            5 &&
                        calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5) {
                  positon = 0;
                }
              }
            }

            bool isVisible = index == snapshot.data!.docs.length - 1 ||
                calculateDifferenceInMinutes(
                    snapshot.data!.docs[index + 1]['timestamp'].toDate(),
                    snapshot.data!.docs[index]['timestamp'].toDate()) >= 5 ||
                positon == 3 ||
                positon == 6
                ? true
                : false;

            var messagesBubble = MessageBubble(
                sender: message['sender'],
                text: message['text'],
                isUser: isYou,
                position: positon,
                isUserNameVisible: isVisible);
            messagesBubbles.add(messagesBubble);
          }
          return Expanded(
              child: ListView.builder(
            itemCount: messagesBubbles.length,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              return messagesBubbles[index];
            },
          ));
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      this.sender,
      required this.text,
      required this.isUser,
      required this.position,
      required this.isUserNameVisible});

  final String? sender;
  final String text;
  final bool isUser;
  final int position;
  final bool isUserNameVisible;

  BorderRadius borderCustomIsUser() {
    if (position == 3) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(10.0),
      );
    } else if (position == 2) {
      return const BorderRadius.only(
        topRight: Radius.circular(10.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(10.0),
      );
    } else if (position == 0) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      );
    }
    return const BorderRadius.only(
      topRight: Radius.circular(10.0),
      topLeft: Radius.circular(30.0),
      bottomLeft: Radius.circular(30.0),
      bottomRight: Radius.circular(30.0),
    );
  }

  BorderRadius borderCustomNotUser() {
    if (position == 4) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(10.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      );
    } else if (position == 5) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(10.0),
        bottomLeft: Radius.circular(10.0),
        bottomRight: Radius.circular(30.0),
      );
    } else if (position == 0) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      );
    }
    return const BorderRadius.only(
      topRight: Radius.circular(30.0),
      topLeft: Radius.circular(30.0),
      bottomLeft: Radius.circular(10.0),
      bottomRight: Radius.circular(30.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(visible: isUserNameVisible, child: Text(sender ?? "")),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 2 / 3,
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius:
                    isUser ? borderCustomIsUser() : borderCustomNotUser(),
              ),
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Text(text,
                    style: TextStyle(
                        color: isUser
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 15.0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
