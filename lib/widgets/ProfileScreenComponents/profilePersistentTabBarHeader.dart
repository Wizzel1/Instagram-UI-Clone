import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/widgets/widgets.dart';

class ProfilePersistentTabBarHeader extends StatelessWidget {
  final TabController tabController;
  final List<Widget> tabs;

  const ProfilePersistentTabBarHeader(
      {Key key, @required this.tabController, @required this.tabs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 50.0,
        maxHeight: 50.0,
        child: Container(
          color: Colors.white,
          child: TabBar(
            onTap: (index) {},
            controller: tabController,
            indicatorColor: Colors.black,
            indicatorWeight: 1.5,
            tabs: tabs,
          ),
        ),
      ),
    );
  }
}
