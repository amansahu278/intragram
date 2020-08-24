import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intragram/models/user.dart';
import 'package:intragram/pages/activity_feed.dart';
import 'package:intragram/pages/create_account.dart';
import 'package:intragram/pages/profile.dart';
import 'package:intragram/pages/search.dart';
import 'package:intragram/pages/timeline.dart';
import 'package:intragram/pages/upload.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final commentsRef = Firestore.instance.collection("comments");
final StorageReference storageRef = FirebaseStorage.instance.ref();
final timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController _pageController;
  int pageIndex = 0;

  logout() async {
    await googleSignIn.signOut();
    print("Signing out\n");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
  }

  Future<FirebaseUser> _handleSignIn() async {
    FirebaseUser user;

    bool isSignedIn = await googleSignIn.isSignedIn();
    print(isSignedIn);
    if (isSignedIn) {
      user = await _auth.currentUser();
    } else {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      user = (await _auth.signInWithCredential(credential)).user;
    }
    return user;
  }

  void signInWithGoogle() async {
    FirebaseUser user = await _handleSignIn();
//    handleSignIn(user);
    print(user);
    if (user != null) {
      print("creating");
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    }
  }

  createUserInFirestore() async {
    //Check if user exists
    GoogleSignInAccount user = googleSignIn.currentUser;
    print("User is $user");
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    print("doc is ${doc.data}");
    //If doesnt exist, then redirect to create account page
    if (doc.data == null) {
      //get username from create account, use it to make a new document in users collection
      final String username = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => CreateAccount()));

      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
      print("data set\n");
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  handleSignIn(account) {
    if (account != null) {
      print('User signed in! : $account');
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

//    // When user signs in
//    googleSignIn.onCurrentUserChanged.listen((account) {
//      print(account);
//      handleSignIn(account);
//    }, onError: (err) {
//      print('Error: $err');
//    });
//
//    //Reauthenticate
//    googleSignIn.signInSilently(suppressErrors: false).then((account) {
//      handleSignIn(account);
//    }, onError: (err) {
//      print('Error: $err');
//    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Theme.of(context).accentColor,
          Theme.of(context).primaryColor
        ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Intragram",
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90.0, color: Colors.white),
            ),
            GestureDetector(
              onTap: signInWithGoogle,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        "assets/images/google_signin_button.png",
                      ),
                      fit: BoxFit.contain),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
          Scaffold(
              body: Center(
            child: RaisedButton(
              child: Text("Logout"),
              onPressed: logout,
            ),
          ))
        ],
        controller: _pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onNavBarChange,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35.0,
              )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          BottomNavigationBarItem(icon: Icon(Icons.cancel)),
        ],
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      this.pageIndex = index;
    });
  }

  void onNavBarChange(int pageIndex) {
    setState(() {
      _pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
//     _pageController.jumpToPage(pageIndex);
    });
  }
}
