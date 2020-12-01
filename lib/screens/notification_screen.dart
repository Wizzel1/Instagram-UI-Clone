import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/widgets/widgets.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: CustomSearchbar(
            height: 110,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Notifications",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: const TabBar(
                    indicatorColor: Colors.black,
                    indicatorWeight: 1.5,
                    tabs: [
                      Tab(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.black,
                        ),
                      ),
                      Tab(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                      ),
                      Tab(
                        icon: const Icon(
                          Icons.person_outline,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return NotificationListTile(title: "Like");
                },
              ),
              ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return NotificationListTile(title: "Share");
                },
              ),
              ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return NotificationListTile(title: "Mention");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationListTile extends StatelessWidget {
  final String title;
  const NotificationListTile({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
      child: ListTile(
        onTap: () => print("tile tapped"),
        leading: CircleAvatar(
          backgroundImage: NetworkImage("https://picsum.photos/350"),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
