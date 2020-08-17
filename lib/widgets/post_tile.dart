import 'package:flutter/material.dart';
import 'package:intragram/widgets/custom_image.dart';
import 'package:intragram/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("Post is selected"),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
