import 'package:flutter/material.dart';

class User {
  final String id;
  final String userId;
  final String userImage;
  final String userContant;
  final String userTime;
  final String userImagePath;

  User(
      {@required this.id,
        @required this.userId,
      @required this.userImage,
      @required this.userContant,
      @required this.userTime,
      @required this.userImagePath});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
      userId: json['user_id'],
      userImage: json['user_image'],
      userContant: json['user_contant'],
      userTime: json['user_time'],
      userImagePath: json['user_image_path']);
}
