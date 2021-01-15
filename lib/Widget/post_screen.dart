import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'user_service.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final contantController = TextEditingController();

  var timeController = DateTime.now().toString();
  UserService userService = new UserService();

  static final String uploadEndPoint =
      'http://www.unityitsolutionprovider.com/AYZ/social_media/post/post_image/fileUpload.php';
  File file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  String filePickedName;
  String filePath;
  final picker = ImagePicker();
  String postID = '1';

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
        filePickedName = file.path.split('/').last;
      });
    } catch (e) {
      print(e);
    }
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  bool _isloading = false;
  _fleshScreen() {
    setState(() {
      _isloading = true;
    });
    userService.getPostData();
    setState(() {
      _isloading = false;
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == file) {
      setStatus(errMessage);
      return;
    }

    upload();
   
  }

  upload() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndPoint));
      request.files.add(await http.MultipartFile.fromPath('image', file.path,
          filename: filePickedName));
      var res = await request.send().then((result) {
        if (result.statusCode == 200) {
          insertMethod();
          
        } else {
          setStatus(errMessage);
        }

        setStatus(result.statusCode == 200 ? 'Success' : errMessage);
      }).catchError((error) {
        setStatus(error);
      });
      return res.reasonPhrase;
    } catch (e) {
      print(e);
    }
  }

  // ???????????????????????????????????????????????????????????

  Future<http.Response> insertMethod() async {
    var response = await http.post(
        "http://www.unityitsolutionprovider.com/AYZ/social_media/insertData.php",
        body: {
          'post_id': postID,
          'post_contant': contantController.text,
          'post_time': timeController,
          'post_image': filePickedName,
          'post_image_path': filePickedName
        });
    return response;
  }

  // ??????????????????????????????????????????????????????????

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(width: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                height: 70.0,
                width: MediaQuery.of(context).size.width / 1.4,
                decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.grey[400]),
                    borderRadius: BorderRadius.circular(5.0)),
                child: TextField(
                  controller: contantController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'What\'s on your mind?',
                  ),
                ),
              ),
              OutlineButton(
                onPressed: chooseImage,
                child: Text('Choose Image'),
              ),
              OutlineButton(
                onPressed: cameraImage,
                child: Text('Camera'),
              ),
              SizedBox(
                height: 10.0,
              ),
              file != null
                  ? Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.file(file, fit: BoxFit.contain),
                    )
                  : Container(height: 0),
              SizedBox(
                height: 20.0,
              ),
              OutlineButton(
                onPressed: () {
                  startUpload();
                  _fleshScreen();
                },
                child: Text(
                  'post',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
