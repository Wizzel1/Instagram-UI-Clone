import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'comment_model.dart';
import 'user_model.dart';

class Post {
  String postID;
  String authorID;
  User author;
  int timeAgo;
  String imageUrl;
  String caption;
  int likes;
  List<Comment> comments;

  Post(
      {@required String imageUrl,
      @required String authorID,
      @required User author}) {
    this.postID = Faker().randomGenerator.string(10);
    this.author = author;
    this.imageUrl = imageUrl;
    this.authorID = authorID;
    this.timeAgo = Faker().randomGenerator.integer(59);
    this.caption = Faker().lorem.sentence();
    this.likes = Faker().randomGenerator.integer(50000);
    this.comments = exampleComments;
  }
}
