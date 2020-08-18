import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intragram/models/user.dart';
import 'package:intragram/pages/edit_profile.dart';
import 'package:intragram/pages/home.dart';
import 'package:intragram/widgets/header.dart';
import 'package:intragram/widgets/post.dart';
import 'package:intragram/widgets/post_tile.dart';
import 'package:intragram/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user;
  String postOrientation = "grid";
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = List();

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 2.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        )
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildButton({String text, Function function}) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black38,
            ),
            borderRadius: BorderRadius.circular(5.0)),
        child: FlatButton(
          onPressed: function,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    //viewing own profile
    bool isOwnerProfile = currentUserId == widget.profileId;
    if (isOwnerProfile) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else {
      return Text("b");
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.only(top: 12, left: 16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        buildCountColumn("Posts", postCount),
                        buildCountColumn("Followers", 120),
                        buildCountColumn("Following", 110),
                      ],
                    ),
                  )
                ],
              ),
//              Container(
//                alignment: Alignment.centerLeft,
//                padding: EdgeInsets.only(top: 12),
//                child: Text(
//                  user.username,
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 16.0
//                  ),
//                ),
//              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  user.bio,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.0, top: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[buildProfileButton()],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/no_content.svg',
                height: 260,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "No Posts",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = new List();
      posts.forEach((element) {
        gridTiles.add(GridTile(child: PostTile(post: element)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          header(context, titleText: user == null ? "Profile" : user.username),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildPostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePost()
        ],
      ),
    );
  }

  buildPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? Theme
              .of(context)
              .primaryColor : Colors.grey,
          onPressed: () => setPostOrientation("grid"),
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? Theme
              .of(context)
              .primaryColor : Colors.grey,
          onPressed: () => setPostOrientation("list"),
        )
      ],
    );
  }
}
