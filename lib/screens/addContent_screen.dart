import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:crop/crop.dart';
import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/screens/editContent_screen.dart';
import 'package:instagram_getx_clone/screens/screens.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:instagram_getx_clone/widgets/MediaPickerComponents/mediaPickerComponents.dart';
import 'package:instagram_getx_clone/widgets/VideoPlayerComponents/videoPlayerComponents.dart';

class AddContentScreen extends StatefulWidget {
  const AddContentScreen({
    Key key,
  }) : super(key: key);

  @override
  _AddContentScreenState createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  PageController _pageController;
  PageController camScreenPageController;
  CropController _cropController;
  int _parentPageIndex = 0;
  int _childPageIndex = 0;
  List<MediaCollection> _collections = [];
  bool _multiSelectable = false;
  bool _zoomPreview = false;
  bool _snapPageView = false;

  @override
  void initState() {
    _pageController = PageController();
    camScreenPageController = PageController();
    _cropController =
        CropController(scale: 2, aspectRatio: 20 / 16); //1000 / 667.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  @override
  void dispose() {
    _cropController.dispose();
    camScreenPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initAsync() async {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    try {
      _collections = await MediaGallery.listMediaCollections(
        mediaTypes: selection.mediaTypes,
      );
      setState(() {});
    } catch (e) {
      print('Failed : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    final MediaCollection allCollection = _collections.firstWhere(
      (collection) => collection.isAllCollection,
      orElse: () {
        return null;
      },
    );

    Widget _getPreviewWidget() {
      if (selection.selectedMedias.last.mediaType == MediaType.image) {
        return FutureBuilder(
          future: selection.selectedMedias.last.getFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Image.file(snapshot.data, fit: BoxFit.contain);
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      } else if (selection.selectedMedias.last.mediaType == MediaType.video) {
        return FutureBuilder(
          future: selection.selectedMedias.last.getFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ChewieVideoPlayer(
                snapshot.data,
                UniqueKey(),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      }
    }

    Widget _buildCropPreview() {
      if (selection.selectedMedias.length == 0) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Crop(
          controller: _cropController,
          helper: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          child: _getPreviewWidget(),
        );
      }
    }

    return Scaffold(
      appBar: buildAppBar(context),
      body: PageView(
        pageSnapping: _snapPageView,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _parentPageIndex = index;
            _childPageIndex = index;
          });
        },
        controller: _pageController,
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: buildPreviewWidget(selection, _buildCropPreview),
              ),
              const SizedBox(height: 2),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _snapPageView = false;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx < -3) {
                      _pageController.animateToPage(1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    } else {
                      _pageController
                          .jumpTo(_pageController.offset - details.delta.dx);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      _snapPageView = true;
                    });
                  },
                  child: allCollection == null
                      ? SizedBox()
                      : MediaGrid(
                          allowMultiSelection: _multiSelectable,
                          collection: allCollection),
                ),
              )
            ],
          ),
          CameraScreen(
            camScreenPageController: camScreenPageController,
            onChangedCamScreenPage: (index) {
              setState(() {
                _childPageIndex = index + 1;
              });
            },
          )
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Future<void> onPressedNext() async {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    if (selection == null) {
      return;
    }
    List<Future<File>> futureFileList = selection.selectedMedias.map((e) async {
      Future<File> future = e.getFile();
      return future;
    }).toList();

    List<File> files = await Future.wait(futureFileList);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContentScreen(files: files),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      centerTitle: true,
      title: Builder(
        builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MaterialButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: Text("Latest"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(child: Text("Next"), onPressed: onPressedNext),
          ],
        ),
      ),
    );
  }

  Widget buildPreviewWidget(
      MediaPickerSelection selection, Widget _buildCropPreview()) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: selection,
          builder: (BuildContext context, Widget child) {
            return _buildCropPreview();
          },
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: IconButton(
            icon: const Icon(Icons.multiple_stop),
            color: Colors.white,
            onPressed: () {
              setState(
                () {
                  _multiSelectable = !_multiSelectable;
                  selection.toggleMultiSelection(_multiSelectable);
                },
              );
            },
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          child: IconButton(
              icon: const Icon(Icons.expand),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  _zoomPreview = !_zoomPreview;
                });
              }),
        )
      ],
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,
      currentIndex: _childPageIndex,
      items: [
        const BottomNavigationBarItem(
          label: "Gallery",
          icon: SizedBox.shrink(),
        ),
        const BottomNavigationBarItem(
          label: "Photo",
          icon: SizedBox.shrink(),
        ),
        const BottomNavigationBarItem(
          label: "Video",
          icon: SizedBox.shrink(),
        ),
      ],
      onTap: (index) {
        if (index == _childPageIndex) return;
        if (_parentPageIndex == 0) {
          if (index == 1) {
            _pageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 2) {
            _pageController
                .animateToPage(1,
                    duration: Duration(milliseconds: 150), curve: Curves.ease)
                .then((value) => camScreenPageController.animateToPage(1,
                    duration: Duration(milliseconds: 150), curve: Curves.ease));
          }
        } else {
          if (index == 0) {
            _pageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 1 && _childPageIndex != 1) {
            camScreenPageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 2 && _childPageIndex != 2) {
            camScreenPageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          }
        }
        setState(() {
          _childPageIndex = index;
          index < 2 ? _parentPageIndex = index : _parentPageIndex = index - 1;
        });
      },
    );
  }
}
