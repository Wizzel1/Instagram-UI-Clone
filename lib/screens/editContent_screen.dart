import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_getx_clone/widgets/VideoPlayerComponents/videoPlayer.dart';

import 'package:mime/mime.dart';

class EditContentScreen extends StatefulWidget {
  final List<File> files;

  EditContentScreen({this.files});

  @override
  _EditContentScreenState createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  FocusNode _focusNode;
  double overlayOpacity = 0;
  bool shareOnFacebook = false;
  bool shareOnTwitter = false;
  bool shareOnTumblr = false;
  Widget thumbnailWidget;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      _setOverlayOpacity();
    });
    _setThumbnailWidget();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios)),
        actions: [
          FlatButton(
            onPressed: _onCreatePostTapped,
            child: Text(
              "Share",
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            buildCaptionContainer(),
            const SizedBox(height: 10.0),
            Expanded(
              child: Stack(
                children: [
                  AbsorbPointer(
                      absorbing: overlayOpacity == 0 ? false : true,
                      child: _buildOptionsListView()),
                  IgnorePointer(
                      ignoring: overlayOpacity == 0 ? true : false,
                      child: _buildOpacityOverlay()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildCaptionContainer() {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AspectRatio(aspectRatio: 1, child: thumbnailWidget),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Bildunterschrift...",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView _buildOptionsListView() {
    return ListView(
      children: [
        ListTile(
          title: Text("Mark people"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => print("Mark people pressed"),
        ),
        const Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text("Add Location"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => print("Add Location pressed"),
        ),
        const Divider(
          thickness: 1,
        ),
        SwitchListTile(
            title: Text("Share on Facebook"),
            value: shareOnFacebook,
            onChanged: (value) {
              setState(() {
                shareOnFacebook = value;
              });
            }),
        const Divider(
          thickness: 1,
        ),
        SwitchListTile(
          title: Text("Share on Twitter"),
          value: shareOnTwitter,
          onChanged: (value) {
            setState(() {
              shareOnTwitter = value;
            });
          },
        ),
        const Divider(
          thickness: 1,
        ),
        SwitchListTile(
          title: Text("Share on Tumblr"),
          value: shareOnTumblr,
          onChanged: (value) {
            setState(() {
              shareOnTumblr = value;
            });
          },
        ),
        const Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text("More options"),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  GestureDetector _buildOpacityOverlay() {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: AnimatedOpacity(
        opacity: overlayOpacity,
        duration: Duration(milliseconds: 200),
        child: Container(
          color: Colors.black,
        ),
      ),
    );
  }

  void _setThumbnailWidget() {
    if (widget.files.isEmpty || widget.files == null) {
      return;
    }

    if (thumbnailWidget != null) {
      return;
    }

    File previewFile = widget.files.last;
    String mimeStr = lookupMimeType(previewFile.path);
    var previewFileType = mimeStr.split('/');

    if (previewFileType.contains("video")) {
      setState(() {
        thumbnailWidget = ChewieVideoPlayer(previewFile, UniqueKey());
      });
    } else if (previewFileType.contains("image")) {
      setState(() {
        thumbnailWidget = Image.file(previewFile, fit: BoxFit.cover);
      });
    }
  }

  void _onCreatePostTapped() {
    print("pressed share");
  }

  void _setOverlayOpacity() {
    setState(() {
      _focusNode.hasFocus ? overlayOpacity = 0.8 : overlayOpacity = 0;
    });
  }
}
