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
  PageController pageController;
  PageController camScreenPageController;
  CropController cropController;
  int parentPageIndex = 0;
  int childPageIndex = 0;
  List<MediaCollection> collections = [];
  List<Media> allMedias;
  bool multiSelectable = false;
  bool zoomPreview = false;
  bool snapPageView = false;
  Widget previewWidget;

  @override
  void initState() {
    pageController = PageController();
    camScreenPageController = PageController();
    cropController =
        CropController(scale: 2, aspectRatio: 20 / 16); //1000 / 667.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  @override
  void dispose() {
    cropController.dispose();
    camScreenPageController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> initAsync() async {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    try {
      collections = await MediaGallery.listMediaCollections(
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
    final MediaCollection allCollection = collections.firstWhere(
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
          controller: cropController,
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
        pageSnapping: snapPageView,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            parentPageIndex = index;
            childPageIndex = index;
          });
        },
        controller: pageController,
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
                      snapPageView = false;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx < -3) {
                      pageController.animateToPage(1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    } else {
                      pageController
                          .jumpTo(pageController.offset - details.delta.dx);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      snapPageView = true;
                    });
                  },
                  child: allCollection == null
                      ? SizedBox()
                      : MediaGrid(
                          allowMultiSelection: multiSelectable,
                          collection: allCollection),
                ),
              )
            ],
          ),
          CameraScreen(
            camScreenPageController: camScreenPageController,
            onChangedCamScreenPage: (index) {
              setState(() {
                childPageIndex = index + 1;
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
                  multiSelectable = !multiSelectable;
                  selection.toggleMultiSelection(multiSelectable);
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
                  zoomPreview = !zoomPreview;
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
      currentIndex: childPageIndex,
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
        if (index == childPageIndex) return;
        if (parentPageIndex == 0) {
          if (index == 1) {
            pageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 2) {
            pageController
                .animateToPage(1,
                    duration: Duration(milliseconds: 150), curve: Curves.ease)
                .then((value) => camScreenPageController.animateToPage(1,
                    duration: Duration(milliseconds: 150), curve: Curves.ease));
          }
        } else {
          if (index == 0) {
            pageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 1 && childPageIndex != 1) {
            camScreenPageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 2 && childPageIndex != 2) {
            camScreenPageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          }
        }
        setState(() {
          childPageIndex = index;
          index < 2 ? parentPageIndex = index : parentPageIndex = index - 1;
        });
      },
    );
  }
}
