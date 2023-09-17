import 'package:chatmanager/Screens/Homepage.dart';
import 'package:chatmanager/auth/LogoutScreens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SettingScreens.dart';
class PopupmenuScreens extends StatefulWidget {
  const PopupmenuScreens({Key? key}) : super(key: key);

  @override
  State<PopupmenuScreens> createState() => _PopupmenuScreensState();
}

class _PopupmenuScreensState extends State<PopupmenuScreens> {
  var name = "";
  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name").toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Homepage"),
          actions: [
            PopupMenuButton(
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingScreens(name:name,)),
                    );
                  }
                  if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LogoutScreens()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Column(children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.purple),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text("Settings"),
                        ],
                      ),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Column(children: [
                      Row(
                        children: [
                          Icon(Icons.remove, color: Colors.purple),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text("Logout"),
                        ],
                      ),
                    ]),
                  ),
                ]),
          ]),
      body: Homepage(),
    );
  }
}
