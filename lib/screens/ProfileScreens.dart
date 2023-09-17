import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProfileScreens extends StatefulWidget {
var updateid = "";
ProfileScreens({required this.updateid});
  @override
  State<ProfileScreens> createState() => _ProfileScreensState();
}

class _ProfileScreensState extends State<ProfileScreens> {
  TextEditingController _name = new TextEditingController();

  getdata() async{
    await FirebaseFirestore.instance.collection("name").doc(widget.updateid).get().then((document){
    _name.text = document["name"].toString();
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
      appBar: AppBar(title: Text("Profile")),
      body: Column(
        children: [
          TextFormField(
            controller: _name,
            keyboardType: TextInputType.name,
          ),
          ElevatedButton(onPressed: () async{
          var name = _name.text.toString();
          await FirebaseFirestore.instance.collection("name").doc(widget.updateid).update({
            "name":name,
          }).then((value){
            Navigator.of(context).pop();
          });
          }, child: Text("save"))
        ],
      ),
    );
  }
}
