import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media/model/comment.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_service.dart';

class CommentWidget extends StatefulWidget {
  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

String status = '';
String commentID = '1';
final commentController = TextEditingController();
String timeController = DateTime.now().toString();
String filePickedName = 'nofile';
UserService userService = new UserService();

String errMessage = 'Error Uploading Image';
String uploadEndPoint =
    'http://www.unityitsolutionprovider.com/AYZ/social_media/comment/comment_image/fileUpload.php';
String imageUrl = "http://www.unityitsolutionprovider.com/AYZ/social_media/";

Future<List<Comment>> getCommentData() async {
  try {
    var url =
        await http.post("http://www.unityitsolutionprovider.com/AYZ/social_media/comment/conn.php");
    var data = jsonDecode(url.body);
    List<Comment> dataList = [];
    for (var d in data) {
      // Comment post = Comment(
      //     id: d['id'],
      //     commentId: d['comment_id'],
      //     commentContant: d['comment_contant'],
      //     commentTime: d['comment_time'],
      //     commentImage: d['comment_image'],
      //     commentImagePath: d['comment_image_path']);
      Comment post = Comment.fromJson(d);
      dataList.add(post);
    }
    return dataList;
  } catch (e) {
    print(e);
  }
}

Future<http.Response> insertMethod() async {
  var response = await http
      .post("http://www.unityitsolutionprovider.com/AYZ/social_media/comment/insertData.php", body: {
    'comment_id': commentID,
    'comment_contant': commentController.text,
    'comment_time': timeController,
    'comment_image': filePickedName,
    'comment_image_path': filePickedName
  });
  return response;
}

Future<http.Response> deleteComment(String id) async {
  print("reach delete");
  print('>>>>>>>>>>>>>>>>>>>>' + id);
  var response = await http.post(
      "http://www.unityitsolutionprovider.com/AYZ/social_media/comment/deleteData.php",
      body: {'id': id});
  print("response ${response.toString()}");
  return response;
}

class _CommentWidgetState extends State<CommentWidget> {
  final picker = ImagePicker();
  File file;
  String status = '';
  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  chooseImage() async {
    try {
      final pickFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        file = File(pickFile.path);
        filePickedName = file.path.split('/').last;
      });
    } catch (e) {
      print(e);
    }

    setStatus('');
  }

  cameraImage() async {
    try {
      final pickFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        file = File(pickFile.path);
        if (file == null) {
          filePickedName = 'nofile';
        } else {
          filePickedName = file.path.split('/').last;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == file) {
      setStatus(errMessage);
      return;
    }

    upload();
  }

  bool _isloading = false;
  _fleshScreen() {
    setState(() {
      _isloading = true;
    });
    userService.getPostData();
    getCommentData();

    setState(() {
      _isloading = false;
    });
  }

  upload() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndPoint));
      request.files.add(await http.MultipartFile.fromPath('image', file.path,
          filename: filePickedName));
      var res = await request.send().then((result) {
        result.statusCode == 200 ? commentController.clear() : print('fail');
        result.statusCode == 200 ? insertMethod() : setStatus(errMessage);

        setStatus(result.statusCode == 200 ? 'Success' : errMessage);
      }).catchError((error) {
        setStatus(error);
      });
      return res.reasonPhrase;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              child: IconButton(
                icon: Icon(
                  Icons.thumb_up,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _fleshScreen();
                },
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: 520,
                child: FutureBuilder(
                    future: getCommentData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Center();
                      } else {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          reverse: true,
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(snapshot.data[index].commentContant),
                                      Text(snapshot.data[index].commentTime,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.grey))
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            '$imageUrl${snapshot.data[index].commentImagePath}')),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "edit") {
                                      } else if (value == "delete") {
                                        deleteComment(snapshot.data[index].id);
                                        getCommentData();
                                        _fleshScreen();
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return {'edit', 'delete'}
                                          .map((String choice) {
                                        return PopupMenuItem<String>(
                                          value: choice,
                                          child: Text(choice),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                if (snapshot.data[index].commentImage ==
                                    'nofile')
                                  Container(
                                    height: 0,
                                  )
                                else
                                  Container(
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'asset/images/placeholder.png',
                                                alignment: Alignment.center,
                                              ),
                                              imageUrl:
                                                  ('$imageUrl${snapshot.data[index].commentImagePath}'),
                                              alignment: Alignment.center,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            );
                          },
                        );
                      }
                    }),
              ),
            ),
            TextField(
              controller: commentController,
              maxLines: 3,
              selectionHeightStyle: BoxHeightStyle.tight,
              decoration: new InputDecoration(
                  hintText: 'Write a Comment',
                  hintStyle: new TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: InkWell(
                    child: Icon(Icons.camera_alt),
                    onTap: () {
                      chooseImage();
                      file != null
                          ? Container(
                              width: double.infinity,
                              height: 100,
                              child: Image.file(file, fit: BoxFit.contain),
                            )
                          : Container(height: 0);
                      SizedBox(
                        height: 0,
                      );
                    },
                  ),
                  suffixIcon: InkWell(
                    child: Icon(
                      Icons.send,
                    ),
                    onTap: () {
                      if (filePickedName == 'nofile') {
                        insertMethod();
                        commentController.clear();
                        _fleshScreen();
                        getCommentData();
                      } else {
                        upload();
                        commentController.clear();
                        _fleshScreen();
                        getCommentData();
                      }
                    },
                  )),
              style: new TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
