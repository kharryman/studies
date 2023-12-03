import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isLoaded = false;

  @override
  void initState() {
    String videoUrl = widget.videoUrl;
    //.replaceAll("https://www.youtube.com", 'http://localhost:3001/YOUTUBE');
    print("LOADING videoUrl = $videoUrl");
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl))
          ..initialize().then((_) {
            setState(() {
              isLoaded = true;
            });
          });
    //chewieController = ChewieController(
    //  videoPlayerController: videoPlayerController,
    //  aspectRatio: 16 / 9, // adjust according to your video aspect ratio
    //  autoPlay: false,
    //  looping: false,
    // other customization options...
    //);
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    //chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoaded == true,
      child: Center(
        child: videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: VideoPlayer(videoPlayerController),
              )
            : Container(),
      ),
    );
  }
}
