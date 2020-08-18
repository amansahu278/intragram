import 'package:flutter/material.dart';
import 'package:intragram/pages/post_screen.dart';
import 'package:intragram/pages/profile.dart';
import 'package:intragram/widgets/custom_image.dart';
import 'package:intragram/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PostScreen(postId: post.postId, userId: post.ownerId)));
  }
}
