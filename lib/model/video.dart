class Video{
  String id;
  String videoUrl;
  String thum;
  Video.fromJson(Map<String,dynamic> data){
    this.videoUrl=data['video'];
    this.id=data['id'];
    this.thum=data['thum'];
  }
}

class VideoList{
  List<Video> videos=[];
  VideoList.fromJson(List<dynamic> data){
    print(data.toString());
    data.forEach((element) {
      print(videos.length.toString());
      videos.add(Video.fromJson(element));
    });
  }
}