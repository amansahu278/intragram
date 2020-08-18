import 'package:flutter/material.dart';

AppBar header(context, { bool isAppTitle = false, String titleText, bool removeBack = false}) {
  return AppBar(
    automaticallyImplyLeading: !removeBack,
    title: Text(
      isAppTitle ? "Intragram" : titleText,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 50.0 : 20,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
