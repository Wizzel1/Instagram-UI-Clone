import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/screens/addContent_screen.dart';
import 'package:instagram_getx_clone/widgets/MediaPickerComponents/mediaPickerSelection.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPicker extends StatefulWidget {
  final MediaPickerSelection initialSelection;

  const MediaPicker({
    Key key,
    this.initialSelection,
  });

  static void showImagePicker(BuildContext context, {int maxImages = 1}) async {
    final mediaStatus = await Permission.photos.status;
    if (mediaStatus.isDenied && Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Not authorized'),
          content: Text(
              "This app can't have access to user media gallery. You must update authorizations in app settings."),
          actions: <Widget>[
            FlatButton(
              child: Text('Open Settings'),
              onPressed: () {
                openAppSettings();
              },
            ),
          ],
        ),
      );
    } else if (await Permission.storage.request().isGranted &&
        (mediaStatus.isGranted ||
            await Permission.photos.request().isGranted)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaPicker(
            initialSelection: MediaPickerSelection(
              mediaTypes: [
                MediaType.image,
                MediaType.video,
              ],
              maxItems: 1,
            ),
          ),
        ),
      );
    }
  }

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  MediaPickerSelection _selection;

  @override
  void initState() {
    _selection = widget.initialSelection ?? MediaPickerSelection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaPickerSelectionProvider(
      selection: _selection,
      child: AddContentScreen(),
    );
  }
}
