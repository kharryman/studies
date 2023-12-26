import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;

  YouTubePlayerScreen({required this.videoId});

  @override
  YouTubePlayerScreenState createState() => YouTubePlayerScreenState();
}

class YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController controller;
  bool canShowVideo = true;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    controller.listen((event) {
      bool retCanShow = false;
      if (event.error == YoutubeError.none) {
        retCanShow = true;
      } else {
        retCanShow = false;
      }
      //print("event.error = ${event.error}");
      print("controller retCanShow: $retCanShow");
      setState(() {
        canShowVideo = retCanShow;
      });

      //YoutubePlayerValue(metaData: YoutubeMetaData(videoId: , title: , author: , duration: 0 sec.), playerState: PlayerState.unStarted, playbackRate: 1, playbackQuality: null, isFullScreen: false, error: YoutubeError.invalidParam)
    });

    controller.setFullScreenListener(
      (isFullScreen) {
        print('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
      },
    );
    //controller.loadVideo('https://www.youtube.com/watch?v=${widget.videoId}');
    //controller.pauseVideo();
  }

  Future<String> awaitController() async {
    await Future.delayed(Duration(seconds: 1));
    return "READY";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: awaitController(),
        builder: (context, snapshot) {
          return YoutubePlayerScaffold(
            aspectRatio: 16 / 9,
            controller: controller,
            builder: (context, player) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  /*
              if (kIsWeb && constraints.maxWidth > 750) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          player,
                          const VideoPositionIndicator(),
                        ],
                      ),
                    ),
                  ],
                );
              }
              */

                  return ListView(
                    children: [player, const VideoPositionIndicator()],
                  );
                },
              );
            },
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class VideoPositionIndicator extends StatelessWidget {
  const VideoPositionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.ytController;

    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position.inMilliseconds ?? 0;
        final duration = controller.metadata.duration.inMilliseconds;

        return LinearProgressIndicator(
          value: duration == 0 ? 0 : position / duration,
          minHeight: 1,
        );
      },
    );
  }
}
