import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';

class MediaPickerSelection extends ChangeNotifier {
  final List<Media> selectedMedias;
  final List<MediaType> mediaTypes;
  int maxItems;

  MediaPickerSelection({
    this.maxItems,
    this.mediaTypes = const <MediaType>[
      MediaType.image,
      MediaType.video,
    ],
    List<Media> selectedMedias,
  }) : selectedMedias = selectedMedias ?? <Media>[];

  static MediaPickerSelection of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<MediaPickerSelectionProvider>();
    assert(provider != null);
    return provider.selection;
  }

  void toggle(Media media) {
    if (maxItems == 1) {
      selectedMedias.clear();
      add(media);
      return;
    }

    if (contains(media)) {
      selectedMedias.length == 1 ? null : remove(media);
    } else {
      add(media);
    }
  }

  void toggleMultiSelection(bool multiSelectEnabled) {
    if (multiSelectEnabled) {
      maxItems = 10;
    } else {
      selectedMedias.isNotEmpty ? clearAllSelectedButLast() : null;
      maxItems = 1;
    }
  }

  void clearAllSelectedButLast() {
    Media lastMedia = selectedMedias.last;
    selectedMedias.clear();
    selectedMedias.add(lastMedia);
  }

  void add(Media media) {
    if (maxItems == null || selectedMedias.length < maxItems) {
      selectedMedias.add(media);
      notifyListeners();
    }
  }

  void remove(Media media) {
    selectedMedias.removeWhere((x) => x.id == media.id);
    notifyListeners();
  }

  bool contains(Media media) {
    return selectedMedias.any((x) => x.id == media.id);
  }
}

class MediaPickerSelectionProvider extends InheritedWidget {
  final MediaPickerSelection selection;

  const MediaPickerSelectionProvider({
    Key key,
    @required Widget child,
    @required this.selection,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(MediaPickerSelectionProvider oldProvider) {
    return selection != oldProvider.selection;
  }
}
