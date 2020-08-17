import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intragram/models/user.dart';
import 'package:intragram/pages/home.dart';
import 'package:intragram/widgets/custom_image.dart';
import 'package:intragram/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((value) {
      if (value == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        likes,
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {

  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map<String, bool> likes = {};
  bool isLiked;
  bool showHeart = false;

  _PostState(likes, {
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
              onTap: () {},
              child: Text(user.username, style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),)
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart ? Animator(
            duration: Duration(milliseconds: 300),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.bounceInOut,
            cycles: 0,
            builder: (context, anim, child) =>
                Transform.scale(
                  scale: anim.value,
                  child: Icon(Icons.favorite, size: 80,
                    color: Colors.white.withOpacity(0.5),),
                ),
          ) : Container()
//          showHeart ? AnimatorIcon(Icons.favorite, size: 80, color: Colors.red,) : Container()
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 40, left: 20.0)
            ),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
                padding: EdgeInsets.only(right: 20.0)
            ),
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, top: 5.0),
              child: Text("$likeCount likes", style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Text("$username", style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),),
              ),
              SizedBox(width: 10,),
              Expanded(child: Text(description),)
            ],
          ),
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
//    print("The likes list is:");
//    print(likes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }

  void handleLikePost() {
    bool _isLiked = (likes[currentUserId] == true);
    print(currentUserId);
    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }
}
