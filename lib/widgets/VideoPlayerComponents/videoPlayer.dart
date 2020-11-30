import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/widgets/VideoPlayerComponents/customVideoPlayerControls.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final File file;
  final UniqueKey newKey;

  ChewieVideoPlayer(this.file, this.newKey)
      : super(
            key:
                newKey); // passing Unique key to dispose old class instance and create new with new data

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  VideoPlayerController _controller;
  ChewieController _chewie;

  @override
  void initState() {
    this._initControllers(this.widget.file);
    super.initState();
  }

  void _initControllers(File file) {
    this._controller = VideoPlayerController.file(file);
    this._chewie = ChewieController(
      videoPlayerController: this._controller,
      autoPlay: false,
      autoInitialize: true,
      aspectRatio: _controller.value.aspectRatio,
      customControls: InstagramVideoPlayerControls(),
    );
  }

  @override
  void dispose() {
    this._controller?.dispose();
    this._chewie?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: this._chewie);
  }
}
