import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/screens/screens.dart';
import 'package:instagram_getx_clone/widgets/MediaPickerComponents/mediaPicker.dart';
import 'package:instagram_getx_clone/widgets/PersistentBottomNavigation/tab_navigator.dart';

class NavigationRoot extends StatefulWidget {
  @override
  _NavigationRootState createState() => _NavigationRootState();
}

class _NavigationRootState extends State<NavigationRoot> {
  Widget currentPage;
  int currentPageIndex = 0;

  List<Widget> pages = [
    FeedScreen(),
    SearchScreen(),
    Container(),
    NotificationScreen(),
    UserProfileScreen(),
  ];

  Map<Widget, GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    _navigatorKeys = {
      pages[0]: GlobalKey<NavigatorState>(),
      pages[1]: GlobalKey<NavigatorState>(),
      pages[3]: GlobalKey<NavigatorState>(),
      pages[4]: GlobalKey<NavigatorState>(),
    };
    currentPage = pages[0];
    super.initState();
  }

  void _selectTab(int index) {
    if (currentPageIndex == 0 && index == 0) {
      FeedScreen fs = pages[0];
      fs.resetScrollControllers();
    }

    if (index == 2) {
      MediaPicker.showImagePicker(context);
      return;
    }

    if (pages[index] == currentPage) {
      _navigatorKeys[pages[index]]
          .currentState
          .popUntil((route) => route.isFirst);
    } else {
      setState(() {
        currentPage = pages[index];
        currentPageIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[currentPage].currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (currentPage != pages[0]) {
            _selectTab(0);

            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(pages[0]),
            _buildOffstageNavigator(pages[1]),
            _buildOffstageNavigator(pages[3]),
            _buildOffstageNavigator(pages[4]),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      currentIndex: currentPageIndex,
      onTap: (index) {
        _selectTab(index);
      },
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(
            Foundation.home,
            size: 25,
          ),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Feather.search,
            size: 25,
          ),
          label: "Search",
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Feather.plus_square,
            size: 25,
          ),
          label: "Upload",
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Feather.heart,
            size: 25,
          ),
          label: "Likes",
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Feather.user,
            size: 25,
          ),
          label: "Profile",
        ),
      ],
    );
  }

  Widget _buildOffstageNavigator(Widget screenToBuild) {
    return Offstage(
      offstage: currentPage != screenToBuild,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[screenToBuild],
        screenToBuild: screenToBuild,
      ),
    );
  }
}
