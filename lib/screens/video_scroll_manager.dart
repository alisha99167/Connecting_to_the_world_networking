import 'dart:convert';

import 'package:LEARNING/components/video_player.dart';
import 'package:LEARNING/model/post.dart';
import 'package:LEARNING/model/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:preload_page_view/preload_page_view.dart';

class VideoScrollManager extends StatefulWidget {
  const VideoScrollManager({Key key}) : super(key: key);

  @override
  _JsonParsingMapState createState() => _JsonParsingMapState();
}

class _JsonParsingMapState extends State<VideoScrollManager> {
  Future<VideoList> data;
  int pageIndex=0;
  PreloadPageController _controller;
  String selectedVideo;


  @override
  void initState() {
    super.initState();
    _controller= new PreloadPageController(initialPage: 0);
    Network network = Network('http://task.takatakapp.xyz/API/index.php?p=showAllVideos');
    data = network.loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: FutureBuilder(
              future: data,
              builder: (context, AsyncSnapshot<VideoList> snapshot) {
                List<Video> allPosts;
                if (snapshot.hasData) {
                  allPosts = snapshot.data.videos;
                  return createListView(allPosts, context);
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }

  Widget createListView(List<Video> data, BuildContext context) {
    return PreloadPageView.builder(
      itemCount: data.length,
      itemBuilder: (context,index){
        return EVideoPlayer(data[index],selectedVideo,index);
      },
      onPageChanged: (int position) {
        setState(() {
          selectedVideo=data[position].id;
        });
      },
      scrollDirection: Axis.vertical,
      preloadPagesCount: 3,
      controller: _controller,
    );
  }
}

class Network {
  final String url;

  Network(this.url);

  Future<VideoList> loadPosts() async {
    print("calling");
    final response = await post(Uri.parse(url),
        body: jsonEncode({
          "fb_id": "0",
          "token":
              "eynBsaVYwIE:APA91bEmLkA0mold83uPz1N570IZjPGwAUE_o93EkDCPjSZ5-sQRxKRRwAEsSpiGvEOFMq06XQxrCx0k1Kbh8GVjYr3OmDjSGikCiJCReVGsM4-hHvPWgYMOaFrP-9HaO1JfWDg7PgZV",
          "type": "related",
          "page": "4",
          "device_id": "af37ba10f52bca24"
        }));
    var decoded = json.decode(response.body);
    if (decoded['code'] == "200") {
      return VideoList.fromJson(decoded['msg']);
    } else {
      throw Exception("failed to get post");
    }
  }
}
