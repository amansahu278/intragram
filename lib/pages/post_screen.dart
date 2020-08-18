import 'package:flutter/material.dart';
import 'package:intragram/pages/home.dart';
import 'package:intragram/widgets/header.dart';
import 'package:intragram/widgets/post.dart';
import 'package:intragram/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Post", isAppTitle: true),
      body: FutureBuilder(
        future: postsRef
            .document(userId)
            .collection('userPosts')
            .document(postId)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return linearProgress();
          }
          Post post = Post.fromDocument(snap.data);
          return Center(
            child: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
