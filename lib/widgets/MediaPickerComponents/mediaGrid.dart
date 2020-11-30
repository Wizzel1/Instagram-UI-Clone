import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/widgets/MediaPickerComponents/mediaPickerSelection.dart';
import 'package:instagram_getx_clone/widgets/MediaPickerComponents/mediaThumbnail.dart';
import 'package:instagram_getx_clone/widgets/MediaPickerComponents/selectable.dart';
import 'package:media_gallery/media_gallery.dart';

class MediaGrid extends StatefulWidget {
  final MediaCollection collection;
  final bool allowMultiSelection;

  MediaGrid({
    Key key,
    @required this.allowMultiSelection,
    @required this.collection,
  }) : super(key: key);

  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid>
    with AutomaticKeepAliveClientMixin {
  List<MediaPage> pages = [];
  bool isLoading = false;

  bool get canLoadMore =>
      !isLoading && pages.isNotEmpty && (!pages.last.isLast);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync(context);
    });
    super.initState();
  }

  Future<void> initAsync(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      pages.add(
        await widget.collection.getMedias(
          mediaType: MediaType.image,
        ),
      );
      pages.add(
        await widget.collection.getMedias(
          mediaType: MediaType.video,
        ),
      );

      _selectLatestItem(context);
      setState(() {});
    } catch (e) {
      print("Failed : $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _selectLatestItem(BuildContext context) {
    final currentSelection = MediaPickerSelection.of(context);
    final Media latestMedia = pages.expand((page) => page.items).first;
    currentSelection.add(latestMedia);
  }

  Future<void> loadMoreMedias() async {
    setState(() {
      isLoading = true;
    });
    try {
      final nextPage = await pages.last.nextPage();
      pages.add(nextPage);
    } catch (e) {} finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaQuery = MediaQuery.of(context);
    final allMedias = pages.expand((page) => page.items).toList();
    allMedias.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    final selection = MediaPickerSelection.of(context);
    final crossAxisCount = (mediaQuery.size.width / 128).ceil();

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        final bool scrollTreshholdPassed =
            scrollInfo.metrics.pixels + mediaQuery.size.height >=
                scrollInfo.metrics.maxScrollExtent;

        if (canLoadMore && scrollTreshholdPassed) {
          loadMoreMedias();
        }
        return false;
      },
      child: GridView(
        children: <Widget>[
          ...allMedias.map<Widget>(
            (media) => AnimatedBuilder(
              key: Key(media.id),
              animation: selection,
              builder: (context, _) => InkWell(
                onTap: () => selection.toggle(media),
                child: Selectable(
                  enableOverlay: widget.allowMultiSelection,
                  isSelected: selection.contains(media),
                  mediaIndex: selection.contains(media)
                      ? selection.selectedMedias.indexOf(media) + 1
                      : 0,
                  child: MediaThumbnailImage(
                    media: media,
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              key: Key("more_loader"),
              child: CircularProgressIndicator(),
            ),
        ],
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1.0,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
