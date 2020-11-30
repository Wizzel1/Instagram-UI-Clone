import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/models/example_data.dart';
import 'package:instagram_getx_clone/widgets/profileScreenComponents/profileScreenComponents.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final List<Widget> myTabs = [
    Tab(
      icon: Icon(
        Icons.grid_on,
        color: Colors.black,
      ),
    ),
    Tab(
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
                    Text(appUser.handle),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
                onPressed: () {},
              ),
              leading: IconButton(
                icon: Icon(
                  Feather.plus,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            ProfileUserDataSection(
              isUser: true,
              user: appUser,
            ),
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
          mentions: appUser.userPosts,
          posts: appUser.mentions,
        ),
      ),
    );
  }
}
