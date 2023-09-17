import 'package:chatmanager/screens/ChatScreens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var phone = "";
  var name = "";
  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name").toString();
      phone = prefs.getString("numbercontroller").toString();
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
        body: (name == "")?Center(
          child: CircularProgressIndicator(),
        )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("name")
                    .where("name", isNotEqualTo: name)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.size <= 0) {
                      return Center(
                        child: Text("No found"),
                      );
                    } else {
                      return ListView(
                        children: snapshot.data!.docs.map((document) {
                          return ListTile(
                            onTap: () {
                              var name = document["name"].toString();
                              var id = document.id.toString();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>ChatScreens(name:name,
                                receiverid:  id)
                              ));
                            },
                            leading: CircleAvatar(backgroundImage: NetworkImage(document["fileurl"].toString())),
                            title: Text(document["name"].toString(),style: TextStyle(fontSize: 20.0),),
                          );
                        }).toList(),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),);

  }
}
