import 'dart:io';

import 'package:chatmanager/screens/ProfileScreens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingScreens extends StatefulWidget {
  var name = "";
  SettingScreens({required this.name});
  @override
  State<SettingScreens> createState() => _SettingScreensState();
}

class _SettingScreensState extends State<SettingScreens> {
  ImagePicker picker = ImagePicker();
  File? selectedimage;
  bool isload = false;
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
        appBar: AppBar(title: Text("Settings")),
        body: (isload)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("name")
                    .where("name", isEqualTo: name)
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
                          var userid = document.id.toString();
                          var oldname = "";
                          var oldurl = "";
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Center(
                                  child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Colors.greenAccent.shade200,
                                          radius: 12.0,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) {
                                                    return Container(
                                                      height: 100.0,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Column(
                                                            children: [
                                                              IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  XFile? photo =
                                                                      await picker.pickImage(
                                                                          source:
                                                                              ImageSource.camera);
                                                                   oldurl =  ImageProvider as String;
                                                                        File(photo!
                                                                            .path);
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "name")
                                                                      .doc(
                                                                          userid)
                                                                      .get()
                                                                      .then(
                                                                          (imagedoc) {
                                                                    setState(
                                                                        () {
                                                                      oldurl = imagedoc[
                                                                              "fileurl"]
                                                                          .toString();
                                                                      oldname =
                                                                          imagedoc["filename"]
                                                                              .toString();
                                                                    });
                                                                  });
                                                                },
                                                                icon: Icon(Icons
                                                                    .photo),
                                                              ),
                                                              Text("Camera"),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 20.0,
                                                          ),
                                                          Column(
                                                            children: [
                                                              IconButton(
                                                                onPressed:
                                                                    () async {
                                                                   XFile?
                                                                      image =
                                                                      await picker.pickImage(
                                                                          source:
                                                                              ImageSource.gallery);
                                                                    oldurl = File(image!.path);
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                       .collection(
                                                                          "name")
                                                                      .doc(
                                                                          userid)
                                                                      .get()
                                                                      .then(
                                                                          (imagedoc) {
                                                                    setState(
                                                                        () {
                                                                      oldurl = imagedoc[
                                                                              "fileurl"]
                                                                          .toString();
                                                                      oldname =
                                                                          imagedoc["filename"]
                                                                              .toString();
                                                                    });
                                                                  });
                                                                },
                                                                icon: Icon(Icons
                                                                    .browse_gallery),
                                                              ),
                                                              Text("Gallary"),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 13.0,
                                              color: Color(0xFF404040),
                                            ),
                                          ),
                                        ),
                                      ),
                                      radius: 38.0,
                                      backgroundImage: (document["fileurl"]
                                                  .toString() !=
                                              null)
                                          ? NetworkImage(
                                              document["fileurl"].toString()):(oldurl!="")
                                          ? NetworkImage(oldurl) as ImageProvider:AssetImage("img/concierge.png")),
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ProfileScreens(
                                          updateid: document.id.toString()),
                                    ));
                                  },
                                  title: Text(document["name"].toString()),
                                ),
                              ],
                            ),
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
              ));
  }
}
