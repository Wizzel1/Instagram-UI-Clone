import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'post_model.dart';

class User {
  String id;
  String userImageUrl;
  String userBio;
  String userName;
  String handle;
  List<Post> userPosts;
  List<Post> mentions;
  List<String> stories;

  List<Post> _createPosts() {
    List<Post> _postList = [];
    for (var i = 0; i < Random().nextInt(6); i++) {
      _postList.add(Post(
          authorID: id,
          author: this,
          imageUrl: 'https://picsum.photos/id/100$i/650'));
    }
    _postList.sort((a, b) => a.timeAgo.compareTo(b.timeAgo));
    return _postList;
  }

  User({@required String userImageUrl}) {
    this.id = Faker().randomGenerator.string(10);
    this.userBio = Faker().lorem.sentence();
    this.userImageUrl = userImageUrl;
    this.userName = Faker().person.firstName();
    this.handle = Faker().internet.userName();
    this.userPosts = _createPosts();
    this.mentions = _createPosts();
  }
}
