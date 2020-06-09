import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String email;
  String displayName;
  String photoUrl;
  String username;
  String bio;

  User({
    this.username,
    this.id,
    this.email,
    this.bio,
    this.displayName,
    this.photoUrl,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      username: doc['username'],
      displayName: doc['displayName'],
    );
  }

}
