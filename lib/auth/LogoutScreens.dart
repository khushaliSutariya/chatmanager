import 'package:chatmanager/auth/LoginScreens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreens extends StatefulWidget {
  const LogoutScreens({Key? key}) : super(key: key);

  @override
  State<LogoutScreens> createState() => _LogoutScreensState();
}

class _LogoutScreensState extends State<LogoutScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove("numbercontroller");
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoginScreens(),
                  ));
                },
                child: Text("Log Out")),
          )
        ],
      ),
    );
  }
}
