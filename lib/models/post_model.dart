import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class Post {
  String postID;
  String authorID;
  int timeAgo;
  String imageUrl;
  String caption;
  int likes;

  Post({@required String imageUrl, @required String authorID}) {
    this.postID = Faker().randomGenerator.string(10);
    this.imageUrl = imageUrl;
    this.authorID = authorID;
    this.timeAgo = Faker().randomGenerator.integer(59);
    this.caption = Faker().lorem.sentence();
    this.likes = Faker().randomGenerator.integer(50000);
  }
}
