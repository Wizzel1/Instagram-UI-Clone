import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/models/example_data.dart';
import 'package:instagram_getx_clone/models/models.dart';
import 'package:instagram_getx_clone/screens/screens.dart';

class PostContainer extends StatelessWidget {
  final Post post;

  const PostContainer({
    this.post,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User author = users.singleWhere((user) => user.id == post.authorID);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          buildAuthorInfoContainer(context, author),
          Image(
            image: NetworkImage(post.imageUrl),
          ),
          buildIconButtonRow(),
          buildLikeInfoContainer(),
          buildCaptionContainer(author),
          buildTimeAgoContainer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Container buildAuthorInfoContainer(BuildContext context, User author) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityProfileScreen(user: author),
                ),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image(
                    image: NetworkImage(author.userImageUrl),
                    height: 40,
                    width: 40,
                  ),
                ),
                SizedBox(width: 10),
                Text(author.userName),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.more_horiz), onPressed: () {})
        ],
      ),
    );
  }

  Container buildTimeAgoContainer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Text(
        "${post.timeAgo} min",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Container buildCaptionContainer(User author) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0),
      width: double.infinity,
      child: RichText(
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(
          children: [
            TextSpan(
                text: author.userName,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            TextSpan(
                text: " ${post.caption}",
                style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Container buildLikeInfoContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
      width: double.infinity,
      child: RichText(
        softWrap: true,
        overflow: TextOverflow.visible,
        text: TextSpan(
          children: [
            TextSpan(text: "Liked by ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "a1x",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            TextSpan(text: ", ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "Wizzel",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            TextSpan(text: " and ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "${post.likes} others",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Row buildIconButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(FontAwesome.heart_o),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(FontAwesome.comment_o),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(FontAwesome.send_o),
              onPressed: () {},
            ),
          ],
        ),
        IconButton(icon: Icon(FontAwesome.bookmark_o), onPressed: () {})
      ],
    );
  }
}
