import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//Here all files
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
  }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    File imageFile,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authCredential;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final reference = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(authCredential.user!.uid + '.png');

        await reference.putFile(imageFile);
        final imageUrl = await reference.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authCredential.user!.uid)
            .set(
          {
            'username': username,
            'email': email,
            'imageUrl': imageUrl,
          },
        );
      }
    } on PlatformException catch (error) {
      var message = 'An error has accurd';

      if (error.message != null) {
        message = error.message.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message.toString()),
        backgroundColor: Colors.black,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
