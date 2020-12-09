import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/models/example_data.dart';
import 'package:instagram_getx_clone/widgets/widgets.dart';
import 'package:instagram_getx_clone/models/models.dart';

class DiscoverFeed extends StatefulWidget {
  final Post focusPost;

  DiscoverFeed({
    Key key,
    this.focusPost,
  }) : super(key: key);

  @override
  _DiscoverFeedState createState() => _DiscoverFeedState();
}

class _DiscoverFeedState extends State<DiscoverFeed> {
  final GlobalKey containerSizeKey = GlobalKey();
  ScrollController _scrollController;
  User user;

  @override
  void initState() {
    _scrollController = ScrollController();
    user =
        users.singleWhere((element) => element.id == widget.focusPost.authorID);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocusPost();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiscoverScreenAppBar(user: user),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: user.userPosts.length,
          itemBuilder: (context, index) {
            return PostContainer(
                key: index == 0 ? containerSizeKey : null,
                post: user.userPosts[index]);
          },
        ),
      ),
    );
  }

  _scrollToFocusPost() {
    double containerSize = _getContainerSize().height;
    for (int i = 0; i < user.userPosts.length; i++) {
      if (user.userPosts.elementAt(i) == widget.focusPost) {
        _scrollController.animateTo(i * containerSize,
            duration: const Duration(milliseconds: 1), curve: Curves.ease);
        break;
      }
    }
  }

  Size _getContainerSize() {
    final RenderBox postContainerRender =
        containerSizeKey.currentContext.findRenderObject();
    final size = postContainerRender.size;
    return size;
  }
}

class DiscoverScreenAppBar extends CustomAppbar {
  DiscoverScreenAppBar({
    Key key,
    @required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            user.userName,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18.0,
            ),
          ),
          Text(
            "Beiträge",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          )
        ],
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
