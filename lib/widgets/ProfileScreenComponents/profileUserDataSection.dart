import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:instagram_getx_clone/models/user_model.dart';

class ProfileUserDataSection extends StatelessWidget {
  final bool isUser;
  final User user;
  const ProfileUserDataSection(
      {Key key, @required this.isUser, @required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1.0,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSubscriberCountsRow(),
                  buildUserBioSection(),
                ],
              ),
            ),
          ),
          buildDynamicButtons(),
        ],
      ),
    );
  }

  Padding buildUserBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.userName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(user.userBio),
        ],
      ),
    );
  }

  Row buildSubscriberCountsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildAvatarBox(),
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${user.userPosts.length}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text("Posts"),
              ],
            )
          ],
        ),
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("1.000.000",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Subscriber"),
              ],
            )
          ],
        ),
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("999",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Subscribed"),
              ],
            )
          ],
        ),
      ],
    );
  }

  Padding buildDynamicButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: isUser
          ? Container(
              width: double.infinity,
              child: OutlineButton(
                onPressed: () {},
                child: Text("Edit your Profile"),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlineButton(
                    onPressed: () => print("test"),
                    child: Text("Subscribe"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlineButton(
                    onPressed: () => print("test"),
                    child: Text("Message"),
                  ),
                ),
                const SizedBox(width: 10),
                ButtonTheme(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minWidth: 0,
                  child: OutlineButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {},
                    child: Icon(Icons.keyboard_arrow_down),
                  ),
                )
              ],
            ),
    );
  }

  SizedBox buildAvatarBox() {
    return isUser
        ? SizedBox(
            height: 120,
            width: 120,
            child: Stack(children: [
              CircleAvatar(
                  radius: 120,
                  backgroundImage: NetworkImage(user.userImageUrl)),
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
                    size: 30,
                  ),
                ),
              )
            ]),
          )
        : SizedBox(
            height: 120,
            width: 120,
            child: CircleAvatar(
              radius: 120,
              backgroundImage: NetworkImage(user.userImageUrl),
            ),
          );
  }
}
