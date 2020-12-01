import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/models/example_data.dart';
import 'package:instagram_getx_clone/models/models.dart';
import 'package:instagram_getx_clone/screens/screens.dart';
import 'package:instagram_getx_clone/widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  FocusNode _focusNode;
  TextEditingController _textController;
  AnimationController _animationController;
  Animation _animation;
  List<User> filteredUsers = users;

  @override
  void initState() {
    _focusNode = FocusNode();
    _textController = TextEditingController();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = IntTween(begin: 10, end: 0).animate(_animationController);
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    _animateAppBar();
  }

  void _animateAppBar() {
    if (_animationController.value == 0.0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: CustomSearchbar(
            height: 110,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (_, child) {
                          return Expanded(
                            flex: _animation.value,
                            child: SizedBox(
                              width: 0.0,
                              child: FittedBox(
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        flex: 70,
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (text) => {
                            filteredUsers = _search(text),
                            setState(() {}),
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            fillColor: Colors.grey[50],
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  width: 0.8, color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  width: 0.8, color: Colors.transparent),
                            ),
                            focusColor: Colors.black,
                            hintText: "Search",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _textController.clear();
                                filteredUsers = users;
                                _focusNode.unfocus();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _focusNode.hasFocus
                      ? Container(
                          key: UniqueKey(),
                          height: 50,
                          child: const TabBar(
                            indicatorColor: Colors.black,
                            indicatorWeight: 1.5,
                            tabs: [
                              const Tab(
                                icon: Icon(
                                  Icons.menu,
                                  color: Colors.black,
                                ),
                              ),
                              const Tab(
                                icon: Icon(
                                  Icons.person_outline,
                                  color: Colors.black,
                                ),
                              ),
                              const Tab(
                                icon: Icon(
                                  Icons.tag,
                                  color: Colors.black,
                                ),
                              ),
                              const Tab(
                                icon: Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          key: UniqueKey(),
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: OutlineButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  borderSide:
                                      BorderSide(color: Colors.grey[200]),
                                  child: Text("Test $index"),
                                  onPressed: () {},
                                ),
                              );
                            },
                          ),
                        ),
                )
              ],
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _focusNode.hasFocus
                ? TabBarView(
                    children: [
                      buildResultList(),
                      buildResultList(),
                      buildResultList(),
                      buildResultList(),
                    ],
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage("https://picsum.photos/350"),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  ListView buildResultList() {
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
          child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityProfileScreen(
                    user: filteredUsers[index] ?? users[index]),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(filteredUsers[index].userImageUrl ??
                  users[index].userImageUrl),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filteredUsers[index].userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  filteredUsers[index].handle,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<User> _search(String queryText) {
  List<User> searchResult = [];

  if (queryText.isNotEmpty) {
    users.forEach((user) {
      if (user.userName.toLowerCase().contains(queryText.toLowerCase()) ||
          user.handle.toLowerCase().contains(queryText.toLowerCase())) {
        searchResult.add(user);
      }
    });
    return searchResult;
  } else {
    return users;
  }
}
