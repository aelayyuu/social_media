import 'package:flutter/material.dart';

class Post {
  final String id;
  final String postId;
  final String postImage;
  final String postContant;
  final String postTime;
  final String postImagePath;

  Post(
      {@required this.id,
        @required this.postId,
      @required this.postImage,
      @required this.postContant,
      @required this.postTime,
      @required this.postImagePath});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      id: json['id'],
      postId: json['post_id'],
      postImage: json['post_image'],
      postContant: json['post_contant'],
      postTime: json['post_time'],
      postImagePath: json['post_image_path']);
      
   Map<String, dynamic> toJson() => {
        
        "post_id": postId,
        "post_image": postImage,
        "post_contant" : postContant,
        "post_time": postTime,
        "post_image_path": postImagePath,

      };
}
