import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class InstagramVideoPlayerControls extends StatefulWidget {
  const InstagramVideoPlayerControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InstagramVideoPlayerControlsState();
  }
}

class _InstagramVideoPlayerControlsState
    extends State<InstagramVideoPlayerControls> {
  VideoPlayerValue _latestValue;
  //double _latestVolume;
  //bool _hideOverlay = true;
  Timer _hideOverlayTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _isDraggingBar = false;
  // bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        //_cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () {}, //_cancelAndRestartTimer(),
        child: Column(
          children: <Widget>[
            _latestValue != null &&
                        !_latestValue.isPlaying &&
                        _latestValue.duration == null ||
                    _latestValue.isBuffering
                ? const Expanded(
                    child: const Center(
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : _buildHitArea(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideOverlayTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null) {
            _playPause();
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity: _latestValue != null &&
                      !_latestValue.isPlaying &&
                      !_isDraggingBar
                  ? 1.0
                  : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.play_arrow, size: 32.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      //_startOveralyHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          //_hideOverlay = false;
        });
      });
    }
  }

  void _playPause() {
    bool isFinished;
    if (_latestValue.duration != null) {
      isFinished = _latestValue.position >= _latestValue.duration;
    } else {
      isFinished = false;
    }

    setState(() {
      if (controller.value.isPlaying) {
        // _hideOverlay = false;
        _hideOverlayTimer?.cancel();
        controller.pause();
      } else {
        // _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }
}
