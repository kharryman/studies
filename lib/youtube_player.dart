import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;

  YouTubePlayerScreen({required this.videoId});

  @override
  YouTubePlayerScreenState createState() => YouTubePlayerScreenState();
}

class YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    _youtubeController = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ));

    super.initState();
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _youtubeController,
      liveUIColor: Colors.amber,
      showVideoProgressIndicator: true,
      bottomActions: [
        CurrentPosition(),
        ProgressBar(
            isExpanded: true,
            colors: const ProgressBarColors(
                playedColor: Colors.amber, handleColor: Colors.amberAccent)),
        const PlaybackSpeedButton()
      ],
      onReady: () => debugPrint("Youtube video ${widget.videoId} ready.."),
    );
  }
}
