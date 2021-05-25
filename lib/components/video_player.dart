import 'dart:ui';

import 'package:LEARNING/model/video.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class EVideoPlayer extends StatefulWidget {
  Video video;
  String selectedVideo;
  int index;

  EVideoPlayer(this.video,this.selectedVideo,this.index);

  @override
  _EVideoPlayerState createState() => _EVideoPlayerState();
}

class _EVideoPlayerState extends State<EVideoPlayer> with SingleTickerProviderStateMixin{
  CachedVideoPlayerController _controller;
  AnimationController _animationController;
  Animation _animation;
  double _opc=0;


  @override
  void didUpdateWidget(covariant EVideoPlayer oldWidget) {
    if(widget.selectedVideo==widget.video.id){
      _controller?.play();
    }else {
      _controller?.pause();
    }
    super.didUpdateWidget(oldWidget);
  }


  @override
  void initState() {
    _controller = CachedVideoPlayerController.network(widget.video.videoUrl)
      ..initialize().then((value){
        if(widget.index==0){
          _controller.play();
        }
        _controller.setLooping(true);
        if(!mounted) return;
        setState(() {
        });
      });
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween(begin: 0.0, end: 1.5).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    super.initState();

  }


  void onTap() async{
    if(_controller.value.isPlaying){
      _controller.pause();
    }else{
      _controller.play();
    }
    if(!mounted) return;
    setState(() {
      _opc=1;
    });
    await Future.delayed(Duration(milliseconds: 300));
    if(!mounted) return;
    setState(() {
      _opc=0;
    });
  }

  void onDoubleTab(){
    _animationController.forward().then((value) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      onDoubleTap : onDoubleTab,
      child: Container(
          margin: EdgeInsets.all(0),
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              !_controller.value.initialized?Center(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ClipRRect(
                        child: Hero(
                          tag: UniqueKey().toString(),
                          child: Material(
                            color:Colors.transparent,
                            child: CachedNetworkImage(
                              imageUrl: widget.video.thum,
                              placeholder: (context, url) => CupertinoActivityIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      CupertinoActivityIndicator()
                    ],
                  )

              ):Center(
                child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CachedVideoPlayer(_controller)),
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.5)
                        ]
                    )
                ),
              ),
              _heartAnimation(),
              _pauseplayanimation(),
            ],
          )
      ),
    );
  }


  _heartAnimation(){
    return Align(
      alignment: Alignment.center,
      child: ScaleTransition(
          scale: _animation,
          child: Center(
              child:Icon(FontAwesomeIcons.solidHeart,color: Colors.redAccent.withOpacity(0.8),size: 100,))
      ),
    );
  }

  _pauseplayanimation(){
    return Align(
      alignment: Alignment.center,
      child: AnimatedOpacity(
          duration: Duration(milliseconds: 400),
          opacity: _opc,
          child: Center(
              child:Icon(_controller.value.isPlaying?FontAwesomeIcons.play:FontAwesomeIcons.pause,color: Colors.white.withOpacity(0.6),size: 60,))
      ),
    );
  }



  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.paused){
      _controller.pause();
    }else
    if(state== AppLifecycleState.resumed){
      _controller.play();
    }
  }

}
