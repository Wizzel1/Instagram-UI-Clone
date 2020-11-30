import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/screens/editContent_screen.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final PageController camScreenPageController;
  final Function onChangedCamScreenPage;

  const CameraScreen({
    Key key,
    this.onChangedCamScreenPage,
    this.camScreenPageController,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  final PageController pageController = PageController();
  CameraController camController;
  List cameras;
  int selectedCameraIndex;
  String imagePath;
  String videoPath;

  @override
  void initState() {
    _initializeCameras();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    camController.dispose();
    super.dispose();
  }

  //---Photo Config ---

  /// Display the control bar with buttons to take pictures
  Widget _photoControlsWidget(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
              child: Icon(Icons.camera),
              backgroundColor: Colors.blueGrey,
              onPressed: () {
                _onCapturePhotoPressed(context);
              },
            )
          ],
        ),
      ),
    );
  }

  void _onCapturePhotoPressed(BuildContext context) async {
    if (!camController.value.isInitialized) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Photos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.png';

    try {
      await camController.takePicture(filePath);
      imagePath = filePath;
      File imageFile = File(imagePath);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditContentScreen(files: [imageFile]),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<String> _startVideoRecording() async {
    if (!camController.value.isInitialized) {
      return null;
    }

    // Do nothing if a recording is on progress
    if (camController.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await camController.startVideoRecording(filePath);
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  //--- Video Config ---

  /// Display the control bar with buttons to record videos.
  Widget _videoControlsWidget(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.videocam),
              color: Colors.blue,
              onPressed: camController != null &&
                      camController.value.isInitialized &&
                      !camController.value.isRecordingVideo
                  ? _onRecordButtonPressed
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              color: Colors.red,
              onPressed: () {
                camController != null &&
                        camController.value.isInitialized &&
                        camController.value.isRecordingVideo
                    ? _onStopButtonPressed(context)
                    : null;
              },
            )
          ],
        ),
      ),
    );
  }

  void _onRecordButtonPressed() {
    _startVideoRecording();
  }

  void _onStopButtonPressed(BuildContext context) {
    if (!camController.value.isRecordingVideo) {
      return null;
    }
    try {
      File test = File(videoPath);

      camController.stopVideoRecording().then(
            (_) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditContentScreen(files: [test]),
              ),
            ),
          );
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  //--- Camera Setup ---

  void _initializeCameras() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });

        _onCameraSwitched(cameras[selectedCameraIndex]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIndex = selectedCameraIndex;
    });
  }

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (camController != null) {
      await camController.dispose();
    }

    camController = CameraController(cameraDescription, ResolutionPreset.high);

    // If the camController is updated then update the UI.
    camController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    try {
      await camController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    if (camController == null || !camController.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    return AspectRatio(
      aspectRatio: camController.value.aspectRatio,
      child: CameraPreview(camController),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _cameraPreviewWidget(),
        ),
        SizedBox(height: 10.0),
        Expanded(
          flex: 1,
          child: PageView(
            controller: widget.camScreenPageController,
            onPageChanged: (index) => widget.onChangedCamScreenPage(index),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _cameraTogglesRowWidget(),
                  _photoControlsWidget(context),
                  Spacer()
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _cameraTogglesRowWidget(),
                  _videoControlsWidget(context),
                  Spacer()
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
