import 'package:flutter/material.dart';

class Comment {
  final String id;
  final String commentId;
  final String commentContant;
  final String commentImage;
  final String commentTime;
  final String commentImagePath;

  Comment(
      {@required this.id,
      @required this.commentId,
      @required this.commentImage,
      @required this.commentContant,
      @required this.commentTime,
      @required this.commentImagePath});

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
      id: json['id'],
      commentId: json['comment_id'],
      commentImage: json['comment_image'],
      commentContant: json['comment_contant'],
      commentTime: json['comment_time'],
      commentImagePath: json['comment_image_path']);

  Map<String, dynamic> toJson() => {
        'comment_id': commentId,
        'comment_image': commentImage,
        'comment_contant': commentContant,
        'comment_time': commentTime,
        'comment_image_path': commentImagePath,
      };
}
