import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/models/example_data.dart';
import 'package:instagram_getx_clone/models/models.dart';
import 'package:instagram_getx_clone/widgets/widgets.dart';
import 'package:instagram_getx_clone/screens/screens.dart';

class FeedScreen extends StatelessWidget {
  final ScrollController _feedSC = ScrollController();
  final ScrollController _storySC = ScrollController();

  void resetScrollControllers() {
    _feedSC.animateTo(
      0.0,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 400),
    );
    _storySC.animateTo(
      0.0,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Post> posts = _getTotalPosts();
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        key: PageStorageKey<String>("Feed"),
        controller: _feedSC,
        child: Column(
          children: [
            const Divider(
              height: 1.0,
            ),
            buildStoriesListView(),
            const Divider(
              height: 1.0,
            ),
            buildPostsListView(posts)
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      centerTitle: true,
      title: const Text(
        "Instaclone",
        style: TextStyle(
          color: Colors.black,
          fontFamily: "Billabong",
          fontSize: 36.0,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Feather.camera,
          color: Colors.black,
        ),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Feather.tv,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            FontAwesome.send_o,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Container buildPostsListView(List<Post> posts) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostContainer(post: posts[index]);
        },
      ),
    );
  }

  Container buildStoriesListView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.white,
      height: 120.0,
      width: double.infinity,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        controller: _storySC,
        itemCount: exampleStories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return UserAddStoryWidget(index: index);
          }
          return StoryWidget(index: index);
        },
      ),
    );
  }

  List<Post> _getTotalPosts() {
    List<Post> _totalPosts = [];

    for (var user in users) {
      _totalPosts += user.userPosts;
    }
    _totalPosts.sort((a, b) => a.timeAgo.compareTo(b.timeAgo));
    return _totalPosts;
  }
}

class StoryWidget extends StatelessWidget {
  final int index;
  const StoryWidget({
    Key key,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //push storyscreen with static function

        StoryScreen.showStoryScreen(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14.0),
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70.0),
              border: Border.all(
                width: 3.0,
                color: Colors.red,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(1),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70.0),
                  child: Image(
                    height: 70,
                    width: 70,
                    image: NetworkImage(users[index].userImageUrl),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "Test",
            style: TextStyle(fontSize: 12.0),
          )
        ],
      ),
    );
  }
}

class UserAddStoryWidget extends StatelessWidget {
  final int index;

  const UserAddStoryWidget({
    Key key,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14.0),
              height: 70,
              width: 70,
              child: Container(
                padding: const EdgeInsets.all(1),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(70.0),
                    child: Image(
                      height: 70,
                      width: 70,
                      image: NetworkImage(users[index].userImageUrl),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Icon(
                  FontAwesome.plus_circle,
                  color: Colors.blue[700],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 10.0),
        const Text(
          "Your story",
          style: TextStyle(fontSize: 12.0),
        )
      ],
    );
  }
}
