import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intragram/models/user.dart';
import 'package:intragram/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;


  handleSearch(String query) {
    Future<QuerySnapshot> users = Firestore.instance.collection("users").where("displayName", isGreaterThanOrEqualTo: query).getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
       decoration: InputDecoration(
         fillColor: Colors.white,
         hintText: "Search for a user...",
         filled : true,
         prefixIcon: Icon(Icons.account_box, size: 28),
         suffixIcon: IconButton(
           icon: Icon(Icons.clear),
           onPressed: clearSearch,
         )
       ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Widget buildNoContent(){
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset('assets/images/search.svg', height: orientation == Orientation.portrait ? 300 : 200,),
            Text("Find Users", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 60),)
          ],
        ),
      ),
    );
  }

  Widget buildSearchResults(){
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        } else {
          List<Text> searchResults = [];
          snapshot.data.documents.forEach((doc){
            User user = User.fromDocument(doc);
            searchResults.add(Text(user.username));
          });
          return ListView(
            children: searchResults,
          );
        }
      },
    ) ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }

  void clearSearch() {
    searchController.clear();
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
