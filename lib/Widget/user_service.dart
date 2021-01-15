import 'package:social_media/model/post.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService{
  insertMethod(){}
  getPostData(){}
  

  Future<List<Post>> getPostdata() async {
    try {
      var url = await http.post(
          "http://www.unityitsolutionprovider.com/AYZ/social_media/conn.php");
      var data = jsonDecode(url.body);

      List<Post> dataList = [];
      for (var d in data) {
        Post post = Post(
            id: d['id'],
            postId: d['post_id'],
            postContant: d['post_contant'],
            postImage: d['post_image'],
            postTime: d['post_time'],
            postImagePath: d['post_image_path']);
        dataList.add(post);
      }
      return dataList;
    } catch (e) {
      print(e);
    }
  }
}
