import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intragram/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      final snackbar = SnackBar(
        content: Text("Welcome! $username"),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(
        Duration(seconds: 2),
        () {
          Navigator.pop(context, username);
        },
      );
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: "Set up", removeBack: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
                      "UserName",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                          onSaved: (val) {
                            username = val;
                          },
                          autovalidate: true,
                          validator: (val) {
                            if (val.isEmpty || val.trim().length < 3) {
                              return "Username too short";
                            } else if (val.trim().length > 15) {
                              return "Username too long";
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Must be of 3 characters atleast")),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0)),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
