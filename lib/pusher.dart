import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  TextEditingController controller = TextEditingController();

  List<MessageModel> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    // messages = [];
    getAllMessage();
    setState(() {

    });
    connect();
    super.initState();
  }

  getSignature(String value) {
    var key = utf8.encode('4f5b460e1892763d5bb0');
    var bytes = utf8.encode(value);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);
    log("HMAC signature in string is: $digest");
    return digest;
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    return {
      "auth": "d3447aae4d2e003fe8d7:${getSignature("$socketId:$channelName")}",
    };
  }
  onEvent(channelEvent) {
    log("-------chat-------> ${channelEvent.data}");
    int senderId = 0;
    var receiverId = '';
    var message = '0';

    final decodedData = jsonDecode(channelEvent.data);
    if (decodedData.containsKey('sender_id')) {
      senderId = decodedData['sender_id'];
      log(senderId.toString());
    }
    if (decodedData.containsKey('receiver_id')) {
      receiverId = decodedData['receiver_id'];
      log(receiverId);
    }
    if (decodedData.containsKey('message')) {
      message = decodedData['message'];
      log(message);
    }
   messages.insert(0, MessageModel(
     senderId:senderId,
     receiverId: int.tryParse(receiverId),
     message: message,
   ));
    setState(() {

    });
  }
  Future<void> connect() async {
    await pusher.init(
        apiKey: 'd3447aae4d2e003fe8d7',
        cluster: 'eu',
        onAuthorizer: onAuthorizer,
        logToConsole: true,
        onError: (message, code, error) {
          log('Pusher error: $message');
        },
        onSubscriptionSucceeded: (channelName, success) {
          log('onSubscriptionSucceeded: $success , $channelName');
        },
        onSubscriptionError: (message, error) {
          log('Pusher subscription error: $message');
        },
        onConnectionStateChange: (currentState, previousState) {
          log('Pusher state changed from $previousState to $currentState');
        },
        onEvent: onEvent);
    await pusher.subscribe(
      channelName: "private-chat.8",
    );
    await pusher.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 5,
        title: Column(
          children: [
            Text(
              'User Name',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: (const Color(0xff333333).withOpacity(.9))),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              'online',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: (const Color(0xff5A5A5A).withOpacity(.8))),
            ),
          ],
        ),
        actions: const [
          Icon(
            Icons.ac_unit_outlined,
            size: 45,
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Expanded(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('Enter a Message'))
                  : ListView.separated(
                      itemBuilder: (context, index) =>
                          messages[index].senderId == 18
                              ? ChatBuble(
                                text: messages[index].message ?? '',
                              )
                              : ChatBubleFriend(
                                  text: messages[index].message ?? '',
                                ),
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 20,
                      ),
                      itemCount: messages.length,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      // height: 60.h,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: controller,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          showCursor: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xffF6F6F6),
                            helperStyle: const TextStyle(
                              height: 1,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                            alignLabelWithHint: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: InputBorder.none,
                            hintText: 'write your message',
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                            errorStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                                height: 1),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: isLoading
                        ? const Center(child: CupertinoActivityIndicator())
                        : Container(
                            width: 53,
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.green.shade300,
                            ),
                            child: IconButton(
                                onPressed: () {
                                  controller.text.isEmpty
                                      ? () {}
                                      : sendMessage();
                                },
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                )),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAllMessage() async {
    final url =
        Uri.parse('http://192.168.1.12/public/api/messages?receiver_id=8');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer 92|8nl0dyXKT48eaROqrBLm2AXGUa7kmiijsg77FN4o968d0ad0',
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = json.decode(response.body);
        log(res.toString());
        for (var item in res['data']) {
          messages.add(MessageModel.fromJson((item)));
        }
        setState(() {

        });
      } else {
        log('Failed to get message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  Future<void> sendMessage() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('http://192.168.1.12/public/api/messages');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer 61|S3jYzLREPpQCG4QWv41XqbpmCvXpVgGSvTxLAcWt10b32ff7',
    };
    final body = jsonEncode({
      "receiver_id": '2',
      "message": controller.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        messages.insert(
            0,
            (MessageModel(
                senderId: 18,
                receiverId:2,
                message: controller.text,
               )));
        setState(() {
          isLoading = false;
        });
        log('Message sent: ${controller.text}');
      } else {
        log('Failed to send message. Status code: ${response.body}');
        log(body);
      }
    } catch (e) {
      log('Error sending message: $e');
    }
    controller.clear();
  }
}

class ChatBuble extends StatelessWidget {
  const ChatBuble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          bottom: 32,
          top: 32,
          right: 32,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          color: Colors.yellow.shade200,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class ChatBubleFriend extends StatelessWidget {
  const ChatBubleFriend({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          bottom: 32,
          top: 32,
          right: 32,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomLeft: Radius.circular(32),
          ),
          color: Colors.green.shade300,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class MessageModel {
  final int? id;
  final int? senderId;
  final int? receiverId;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        senderId: json["sender_id"],
        receiverId: json["receiver_id"],
        message: json["message"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message": message,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
