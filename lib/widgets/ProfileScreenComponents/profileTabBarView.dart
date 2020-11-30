import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/models/example_data.dart';
import 'package:instagram_getx_clone/models/models.dart';
import 'package:instagram_getx_clone/screens/discoverFeed_screen.dart';

class ProfileTabBarView extends StatelessWidget {
  final TabController tabController;
  final List<Post> posts;
  final List<Post> mentions;
  final bool isUser;

  const ProfileTabBarView(
      {Key key,
      @required this.tabController,
      @required this.isUser,
      @required this.posts,
      @required this.mentions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: _buildTabBarViews(),
    );
  }

  List<Widget> _buildTabBarViews() {
    List<Widget> tabBarViews = [];
    for (var i = 0; i < tabController.length - 1; i++) {
      if (i == 0) {
        tabBarViews.add(
          Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  posts.length > 0
                      ? SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiscoverFeed(
                                      focusPost: posts[index],
                                    ),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(posts[index].imageUrl),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: posts.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1,
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2),
                        )
                      : SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Icon(
                                  Feather.plus_circle,
                                  size: 100,
                                ),
                                const SizedBox(height: 20),
                                Text("Share Fotos and Videos"),
                                const SizedBox(height: 20),
                                Text(
                                    "When you share Fotos and Videos, \n they will be shown in your Profile."),
                                const SizedBox(height: 30),
                                Text("Share your first Foto or Video"),
                              ],
                            ),
                          ),
                        )
                ],
              );
            },
          ),
        );
      }
    }

    tabBarViews.add(
      Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              users[0].mentions.length > 0
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            height: 10,
                            color: Colors.green,
                          ),
                        );
                      }, childCount: 200),
                    )
                  : SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Icon(
                              Feather.plus_circle,
                              size: 100,
                            ),
                            const SizedBox(height: 20),
                            Text("Share Fotos and Videos"),
                            const SizedBox(height: 20),
                            Text(
                                "When you share Fotos and Videos, \n they will be shown in your Profile."),
                            const SizedBox(height: 30),
                            Text("Share your first Foto or Video"),
                          ],
                        ),
                      ),
                    )
            ],
          );
        },
      ),
    );

    return tabBarViews;
  }
}
