import 'dart:async';

import 'package:chatmanager/Screens/Homepage.dart';
import 'package:chatmanager/auth/LoginScreens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PopupmenuScreens.dart';
class SplashScreens extends StatefulWidget {
  const SplashScreens({Key? key}) : super(key: key);

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {

  void resetNewLaunch() async {
    Timer(Duration(seconds: 3), () async {
      if (!mounted) return;
      SharedPreferences _prefs =
      await SharedPreferences.getInstance();
      if (_prefs.containsKey("numbercontroller")) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => new PopupmenuScreens()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => new LoginScreens()));
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    resetNewLaunch();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body:Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Text("Chatmanager",style: TextStyle(fontSize: 15.0),)),
      ],
    ),);
  }
}
