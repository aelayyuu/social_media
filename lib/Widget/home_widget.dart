import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:social_media/model/post.dart';
import 'post_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'comment_widget.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidget createState() => _HomeWidget();
}

class _HomeWidget extends State<HomeWidget> {
  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  String videoUrl1 = 'https://www.youtube.com/watch?v=j5-yKhDd64s';
  YoutubePlayerController _controller1;

  String videoUrl2 = 'https://www.youtube.com/watch?v=E1ZVSFfCk9g';
  YoutubePlayerController _controller2;

  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _fleshScreen();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();
  bool _isloading = false;
  var id;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  static final String imageUrl =
      "http://www.unityitsolutionprovider.com/AYZ/social_media/post/post_image/";

  Future<List<Post>> getPostData() async {
    try {
      var url = await http.post(
          "http://www.unityitsolutionprovider.com/AYZ/social_media/conn.php");
      var data = jsonDecode(url.body);
      print("data >>>> $data");

      List<Post> dataList = [];
      for (var d in data) {
        // Post post = Post(
        //     id: d['id'],
        //     postId: d['post_id'],
        //     postContant: d['post_contant'],
        //     postImage: d['post_image'],
        //     postTime: d['post_time'],
        //     postImagePath: d['post_image_path']);
        Post post = Post.fromJson(d);
        print('LLLLLLLLLLLLLLLLLL' + dataList.toString());
        dataList.add(post);
      }
      return dataList;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getPostData();
    _fleshScreen();
    _enablePlatformOverrideForDesktop();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _controller1 = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(videoUrl1));
    _controller2 = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(videoUrl2));
    super.initState();
  }

  _fleshScreen() {
    setState(() {
      _isloading = true;
    });
    getPostData();
    setState(() {
      _isloading = false;
    });
  }

  void _enablePlatformOverrideForDesktop() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = _showErrorSnackBarMsg());
        break;
    }
  }

  getId(String getId) async {
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
        _fleshScreen();
      }
      return dataList;
    } catch (e) {
      print(e);
    }
  }

  Future<http.Response> deleteMethod(String id) async {
    print("reach delete");
    print('>>>>>>>>>>>>>>>>>>>>' + id);
    var response = await http.post(
        "http://www.unityitsolutionprovider.com/AYZ/social_media/deleteData.php",
        body: {'id': id});
    _fleshScreen();
    print("response ${response.toString()}");
    return response;
  }

  _showErrorSnackBarMsg() {
    _scaffoldstate.currentState.showSnackBar(new SnackBar(
      backgroundColor: Colors.black26,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            color: Colors.redAccent,
            size: 30,
          ),
          SizedBox(width: 18),
          new Text(
            ('$_connectionStatus'),
            style: TextStyle(color: Colors.redAccent, fontSize: 20),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PostScreen()));
          getPostData().then((value) {
            _fleshScreen();
          });
        },
        child: Icon(Icons.add),
      ),
      key: _scaffoldstate,
      appBar: AppBar(
        title: Text("Unity IT Solution Social Media"),
      ),
      body: FutureBuilder(
          future: getPostData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListView.separated(
                // reverse: true,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  // int i =( index+snapshot.data.length) - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // id = snapshot.data[index].postId,
                            Text(snapshot.data[index].postContant),
                            Text(snapshot.data[index].postTime,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.grey))
                          ],
                        ),
                        leading: CircleAvatar(
                          radius: 30,
                          child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  '$imageUrl${snapshot.data[index].postImage}')),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "edit") {
                            } else if (value == "delete") {
                              deleteMethod(snapshot.data[index].id);
                              _fleshScreen();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'edit', 'delete'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      // SizedBox(height: 20.0),
                      // YoutubePlayer(controller: _controller1),
                      // SizedBox(height: 10.0),
                      // SizedBox(height: 20.0),
                      // YoutubePlayer(controller: _controller2),
                      // SizedBox(height: 10.0),
                      Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Image.asset(
                                  'asset/images/placeholder.png',
                                  alignment: Alignment.center,
                                ),
                                imageUrl:
                                    ('$imageUrl${snapshot.data[index].postImage}'),
                                alignment: Alignment.center,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            FlatButton(
                              child: Text("Comment"),
                              onPressed: () {
                                showBottomSheet(
                                    context: context,
                                    builder: (context) => CommentWidget());
                                _fleshScreen();
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          }),
    );
  }
}
