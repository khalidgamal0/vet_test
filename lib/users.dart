import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vet_chat/pusher.dart';

class UserChat extends StatefulWidget {
  const UserChat({super.key});
  @override
  State<UserChat> createState() => _UserChatState();
}
class _UserChatState extends State<UserChat> {
  List <UserModel> userModel=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.green.shade300,
          ),
          title: const Text(
            'Messages',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xff333333)),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.separated(
            itemBuilder: (context, index) =>  InkWell(
              onTap: (){
                // Navigator.push(context, MaterialPageRoute(builder:(context) => const ChatScreen(),));
                getAllDoc();
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('http://api.ejark.sa/assets/images/avatar.png',),
                  ),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'data',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0XFF519273)),
                      ),
                      const SizedBox(height: 2,),
                      Text(
                        'Click to enter the chat',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0XFF333333).withOpacity(.7)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox(
              height: 20,
            ),
            itemCount: 15,
          ),
        ));
  }

  getAllDoc() async {
    final url =
    Uri.parse('http://192.168.1.12/public/api/user');
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
        for (var item in res) {
          userModel.add(UserModel.fromJson(item));
          setState(() {
          });
        }
      } else {
        log('Failed to get use: ${response.body}');
      }
    } catch (e) {
      log('Error getting user: $e');
    }
  }
}

class UserModel {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final dynamic emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? roleId;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.roleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    roleId: json["role_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "role_id": roleId,
  };
}
