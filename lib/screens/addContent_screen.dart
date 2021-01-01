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
  PageController _pageController;
  PageController camScreenPageController;
  CropController _cropController;
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

  void customAnimatePageView(DragUpdateDetails details) {
    if (details.delta.dx < -3) {
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _pageController.jumpTo(_pageController.offset - details.delta.dx);
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

    return Scaffold(
      appBar: AddContentScreenAppBar(
        onPressedNext: onPressedNext,
      ),
      body: PageView(
        pageSnapping: _snapPageView,
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
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
                        _multiSelectable = !_multiSelectable;
                        selection.toggleMultiSelection(_multiSelectable);
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
                          allowMultiSelection: _multiSelectable,
                          collection: allCollection),
                ),
              )
            ],
          ),
          CameraScreen(
            camScreenPageController: camScreenPageController,
          )
        ],
      ),
      bottomNavigationBar: AddContentBottomNavBar(
        pageController: _pageController,
        camPageController: camScreenPageController,
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

typedef OnIndexChanged = void Function(int a, int b);

class AddContentBottomNavBar extends StatefulWidget {
  final PageController pageController;
  final PageController camPageController;
  final OnIndexChanged onIndexChanged;

  AddContentBottomNavBar(
      {Key key,
      @required this.pageController,
      @required this.camPageController,
      @required this.onIndexChanged})
      : super(key: key);

  @override
  _AddContentBottomNavBarState createState() => _AddContentBottomNavBarState();
}

class _AddContentBottomNavBarState extends State<AddContentBottomNavBar> {
  int _childPageIndex = 0;
  int _parentPageIndex = 0;

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
      currentIndex: _childPageIndex,
      items: _navBarItems,
      onTap: (index) {
        if (index == _childPageIndex) return;
        if (_parentPageIndex == 0) {
          if (index == 1) {
            widget.pageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 2) {
            widget.pageController
                .animateToPage(1,
                    duration: Duration(milliseconds: 150), curve: Curves.ease)
                .then((value) => widget.camPageController.animateToPage(1,
                    duration: Duration(milliseconds: 150), curve: Curves.ease));
          }
        } else {
          if (index == 0) {
            widget.pageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 1 && _childPageIndex != 1) {
            widget.camPageController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          } else if (index == 2 && _childPageIndex != 2) {
            widget.camPageController.animateToPage(1,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          }
        }
        setState(() {
          _childPageIndex = index;
          index < 2 ? _parentPageIndex = index : _parentPageIndex = index - 1;
        });
        widget.onIndexChanged(_childPageIndex, _parentPageIndex);
      },
    );
  }
}
