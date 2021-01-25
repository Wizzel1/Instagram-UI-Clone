import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/models/models.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text("Comments", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.mail),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostDetailTile(post: post),
            Divider(),
            CommentList(post: post)
          ],
        ),
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  const CommentList({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: post.comments.length,
      itemBuilder: (BuildContext context, int index) {
        return PostCommentTile(comment: post.comments[index]);
      },
    );
  }
}

class PostDetailTile extends StatelessWidget {
  const PostDetailTile({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(post.author.userImageUrl),
      ),
      title: Row(
        children: [Text(post.author.userName), Text(post.caption)],
      ),
    );
  }
}

class PostCommentTile extends StatelessWidget {
  const PostCommentTile({
    Key key,
    @required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(comment.authorImageUrl),
      ),
      title: Wrap(
        children: [
          RichText(
            text: TextSpan(
              text: comment.authorName,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              children: [
                TextSpan(
                  text: " ${comment.text}",
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                )
              ],
            ),
          ),
        ],
      ),
      subtitle: Row(),
      trailing: Icon(
        Icons.favorite,
      ),
    );
  }
}
