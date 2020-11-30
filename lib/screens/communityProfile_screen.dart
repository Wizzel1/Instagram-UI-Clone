import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/models/models.dart';
import 'package:instagram_getx_clone/widgets/profileScreenComponents/profileScreenComponents.dart';

class CommunityProfileScreen extends StatefulWidget {
  final User user;

  const CommunityProfileScreen({Key key, this.user}) : super(key: key);

  @override
  _CommunityProfileScreenState createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen>
    with SingleTickerProviderStateMixin {
  final List<Widget> myTabs = [
    const Tab(
      icon: Icon(
        Icons.grid_on,
        color: Colors.black,
      ),
    ),
    const Tab(
      icon: Icon(
        FontAwesome5.user,
        color: Colors.black,
      ),
    ),
  ];

  TabController _tabController;
  ScrollPhysics _scrollPhysics;
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        physics: _scrollPhysics,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              brightness: Brightness.light,
              centerTitle: true,
              title: FlatButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.user.handle),
                    Icon(Icons.check),
                  ],
                ),
                onPressed: () {},
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
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            ProfileUserDataSection(isUser: false, user: widget.user),
            ProfileHighlightStories(),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: ProfilePersistentTabBarHeader(
                  tabController: _tabController, tabs: myTabs),
            ),
          ];
        },
        body: ProfileTabBarView(
          tabController: _tabController,
          isUser: true,
          mentions: widget.user.mentions,
          posts: widget.user.userPosts,
        ),
      ),
    );
  }
}
