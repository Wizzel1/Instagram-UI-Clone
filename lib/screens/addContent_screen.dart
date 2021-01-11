import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:crop/crop.dart';
import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/screens/editContent_screen.dart';
import 'package:instagram_getx_clone/screens/screens.dart';
import 'package:instagram_getx_clone/widgets/customSearchbar.dart';
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
  PageController addContentScreenPC;
  PageController camScreenPC;
  CropController _cropController;
  List<MediaCollection> _mediaCollections = [];
  bool _multiSelectEnabled = false;
  bool _zoomPreview = false;
  bool _snapPageView = false;
  int navBarIndex = 0;

  @override
  void initState() {
    addContentScreenPC = PageController();
    camScreenPC = PageController();
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
    camScreenPC.dispose();
    addContentScreenPC.dispose();
    super.dispose();
  }

  Future<void> initAsync() async {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    try {
      _mediaCollections = await MediaGallery.listMediaCollections(
        mediaTypes: selection.mediaTypes,
      );
      setState(() {});
    } catch (e) {
      print('Failed : $e');
    }
  }

  void customAnimatePageView(DragUpdateDetails details) {
    if (details.delta.dx < -3) {
      addContentScreenPC.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      addContentScreenPC.jumpTo(addContentScreenPC.offset - details.delta.dx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    final MediaCollection allCollection = _mediaCollections.firstWhere(
      (collection) => collection.isAllCollection,
      orElse: () {
        return null;
      },
    );

    Future<void> animatePageControllerToPage(
        int pageIndex, int milliseconds) async {
      await addContentScreenPC.animateToPage(pageIndex,
          duration: Duration(milliseconds: milliseconds), curve: Curves.ease);
    }

    Future<void> animateCamPageControllerToPage(
        int pageIndex, int milliseconds) async {
      await camScreenPC.animateToPage(pageIndex,
          duration: Duration(milliseconds: milliseconds), curve: Curves.ease);
    }

    void handleNavBarTapped(int index) {
      print(index);
      if (addContentScreenPC.page == 0) {
        if (index == 1) {
          animatePageControllerToPage(1, 300);
        } else if (index == 2) {
          //jump to photo page,then to video page
          animatePageControllerToPage(1, 150)
              .then((value) => animateCamPageControllerToPage(1, 150));
        }
      } else {
        if (index == 0) {
          animatePageControllerToPage(0, 300);
        } else if (index == 1 && navBarIndex != 1) {
          animatePageControllerToPage(1, 150)
              .then((value) => animateCamPageControllerToPage(0, 150));
        } else if (index == 2 && navBarIndex != 2) {
          animatePageControllerToPage(1, 150)
              .then((value) => animateCamPageControllerToPage(1, 150));
        }
      }
    }

    return Scaffold(
      appBar: AddContentScreenAppBar(
        onPressedNext: onPressedNext,
      ),
      body: PageView(
        pageSnapping: _snapPageView,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (value) => setState(() {
          navBarIndex = value;
        }),
        controller: addContentScreenPC,
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: CropPreview(
                  selection: selection,
                  onMultiSelectPressed: () {
                    setState(
                      () {
                        _multiSelectEnabled = !_multiSelectEnabled;
                        selection.toggleMultiSelection(_multiSelectEnabled);
                      },
                    );
                  },
                  onZoomPreviewPressed: () {
                    setState(() {
                      _zoomPreview = !_zoomPreview;
                    });
                  },
                  cropController: _cropController,
                ),
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
                    customAnimatePageView(details);
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      _snapPageView = true;
                    });
                  },
                  child: allCollection == null
                      ? SizedBox()
                      : MediaGrid(
                          allowMultiSelection: _multiSelectEnabled,
                          collection: allCollection),
                ),
              )
            ],
          ),
          CameraScreen(
            camScreenPageController: camScreenPC,
            onChangedCamScreenPage: (index) => setState(() {
              navBarIndex = index + 1;
            }),
          )
        ],
      ),
      bottomNavigationBar: AddContentBottomNavBar(
        navBarIndex: navBarIndex,
        onNavBarTap: (index) {
          handleNavBarTapped(index);
        },
      ),
    );
  }

  Future<void> onPressedNext() async {
    final MediaPickerSelection selection = MediaPickerSelection.of(context);
    if (selection == null) {
      return;
    }

    List<Future<File>> futureFileList =
        getFileFuturesListOfSelection(selection);

    List<File> files = await Future.wait(futureFileList);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContentScreen(files: files),
      ),
    );
  }

  List<Future<File>> getFileFuturesListOfSelection(
      MediaPickerSelection selection) {
    List<Future<File>> fileFutureList = selection.selectedMedias.map((e) async {
      Future<File> future = e.getFile();
      return future;
    }).toList();
    return fileFutureList;
  }
}

class AddContentScreenAppBar extends CustomAppbar {
  final Function onPressedNext;

  AddContentScreenAppBar({@required this.onPressedNext});

  @override
  Widget build(BuildContext context) {
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
}

class CropPreview extends StatelessWidget {
  final MediaPickerSelection selection;
  final CropController cropController;
  final Function onMultiSelectPressed;
  final Function onZoomPreviewPressed;

  const CropPreview(
      {Key key,
      @required this.selection,
      @required this.onMultiSelectPressed,
      @required this.onZoomPreviewPressed,
      @required this.cropController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: selection,
          builder: (BuildContext context, Widget child) {
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
          },
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: IconButton(
            icon: const Icon(Icons.multiple_stop),
            color: Colors.white,
            onPressed: onMultiSelectPressed,
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          child: IconButton(
              icon: const Icon(Icons.expand),
              color: Colors.white,
              onPressed: onZoomPreviewPressed),
        )
      ],
    );
  }

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
}

class AddContentBottomNavBar extends StatefulWidget {
  final int navBarIndex;
  final Function onNavBarTap;

  AddContentBottomNavBar(
      {Key key, @required this.navBarIndex, @required this.onNavBarTap})
      : super(key: key);

  @override
  _AddContentBottomNavBarState createState() => _AddContentBottomNavBarState();
}

class _AddContentBottomNavBarState extends State<AddContentBottomNavBar> {
  final List<BottomNavigationBarItem> _navBarItems = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,
      currentIndex: widget.navBarIndex,
      items: _navBarItems,
      onTap: (index) {
        widget.onNavBarTap(index);
      },
    );
  }
}
