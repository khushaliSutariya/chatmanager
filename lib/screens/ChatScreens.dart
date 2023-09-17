import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:uuid/uuid.dart';

class ChatScreens extends StatefulWidget {
  var name = "";
  var receiverid = "";
  ChatScreens({required this.name, required this.receiverid});
  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  TextEditingController _msg = TextEditingController();
  ScrollController _scrollController = new ScrollController();
   ImagePicker picker = ImagePicker();
  File ?selectimage;
  var sid = "";
  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sid = prefs.getString("senderid").toString();
    });
  }
  bool emojiShowing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: (sid!="")? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("name")
                      .doc(sid)
                      .collection("chats")
                      .doc(widget.receiverid)
                      .collection("massages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.size <= 0) {
                        return Center(
                          child: Text("No messages"),
                        );
                      } else {
                        return ListView(
                          controller: _scrollController,
                          reverse: true,
                          children: snapshot.data!.docs.map((document) {
                            var time = document["timestamp"].toString();
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
                            String myDate = DateFormat('dd/MM/yyyy,hh:mm').format(date);
                            if (document["senderid"] == sid) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  padding: EdgeInsets.all(10.0),
                                  color: Colors.red.shade500,
                                  child:(document["type"] == "text")?
                                       Column(
                                         children: [
                                           Text(
                                    document["msg"].toString(),
                                    style: TextStyle(
                                            color: Colors.white),
                                  ),
                                           Text(myDate,style: TextStyle(color: Colors.white),),
                                         ],
                                       ):Column(
                                         children: [
                                           Image.network(document["msg"].toString(),width: 100.0),
                                           Text(myDate,style: TextStyle(color: Colors.white),),
                                         ],
                                       ),

                                ),
                              );
                            } else {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  color: Colors.red.shade800,
                                  padding: EdgeInsets.all(10.0),
                                  child: (document["type"] == "text")?
                                  Column(
                                    children: [
                                      Text(
                                        document["msg"].toString(),
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(myDate, style: TextStyle(
                                          color: Colors.white),)
                                    ],
                                  ):Column(
                                    children: [
                                      Image.network(document["msg"].toString(),width:100.0),
                                      Text(myDate, style: TextStyle(
                                          color: Colors.white),),
                                    ],
                                  ),


                                ),
                              );
                            }
                          }).toList(),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }):SizedBox()
            ),
            Container(
              margin: EdgeInsets.all(12.0),
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35.0),
                        boxShadow: const [
                          BoxShadow(
                              offset: Offset(0, 2),
                              blurRadius: 7,
                              color: Colors.grey)
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.mood,
                              color: Color(0xFF00BFA5),
                            ),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                emojiShowing = !emojiShowing;
                              });
                            },
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _msg,
                              onTap: ()
                              {
                                setState(() {
                                  emojiShowing=false;
                                });
                              },
                              decoration: InputDecoration(
                                  hintText: "Message",
                                  hintStyle:
                                      TextStyle(color: Color(0xFF00BFA5)),
                                  border: InputBorder.none),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file,
                                color: Color(0xFF00BFA5)),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_camera,
                                color: Color(0xFF00BFA5)),
                            onPressed: () async{
                              // _scrollController.animateTo(
                              //     _scrollController.position.minScrollExtent,
                              //     duration: Duration(milliseconds: 2),
                              //     curve: Curves.easeOut);
                               XFile? photo = await picker.pickImage(source: ImageSource.camera);
                                 selectimage = File(photo!.path);
                               var uuid = Uuid();
                               var filename = uuid.v1()+".jpg";
                              await FirebaseStorage.instance.ref(filename).putFile(selectimage!).
                              whenComplete((){}).then((filedata) async{
                                await filedata.ref.getDownloadURL().then((fileurl) async{
                                  await FirebaseFirestore.instance
                                      .collection("name")
                                      .doc(sid)
                                      .collection("chats")
                                      .doc(widget.receiverid.toString())
                                      .collection("massages")
                                      .add({
                                    "senderid": sid,
                                    "receiverid": widget.receiverid.toString(),
                                    "msg": fileurl,
                                    "type": "image",
                                    "timestamp": DateTime.now().millisecondsSinceEpoch,

                                  }).then((value) async {
                                    await FirebaseFirestore.instance
                                        .collection("name")
                                        .doc(widget.receiverid.toString())
                                        .collection("chats")
                                        .doc(sid)
                                        .collection("massages")
                                        .add({
                                      "senderid": sid,
                                      "receiverid": widget.receiverid.toString(),
                                      "msg": fileurl,
                                      "type": "image",
                                      "timestamp": DateTime.now().millisecondsSinceEpoch,

                                    }).then((value) {
                                      _msg.text = "";
                                    });
                                  });
                                });
                              });

                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                        color: Color(0xFF00BFA5), shape: BoxShape.circle),
                    child: InkWell(
                      onTap: () async {
                        // _scrollController.animateTo(
                        //     _scrollController.position.minScrollExtent,
                        //     duration: Duration(milliseconds: 2),
                        //     curve: Curves.easeOut);
                        print("Sender : "+sid);
                        print("Receiver : "+widget.receiverid.toString());
                        var msg = _msg.text.toString();
                        await FirebaseFirestore.instance
                            .collection("name")
                            .doc(sid)
                            .collection("chats")
                            .doc(widget.receiverid.toString())
                            .collection("massages")
                            .add({
                          "senderid": sid,
                          "receiverid": widget.receiverid.toString(),
                          "msg": msg,
                          "type": "text",
                          "timestamp": DateTime.now().millisecondsSinceEpoch,
                        }).then((value) async {
                          await FirebaseFirestore.instance
                              .collection("name")
                              .doc(widget.receiverid.toString())
                              .collection("chats")
                              .doc(sid)
                              .collection("massages")
                              .add({
                            "senderid": sid,
                            "receiverid": widget.receiverid.toString(),
                            "msg": msg,
                            "type": "text",
                            "timestamp": DateTime.now().millisecondsSinceEpoch,

                          }).then((value) {
                            _msg.text = "";
                          });
                        });
                      },
                      child: Icon(
                        Icons.keyboard_voice,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            (emojiShowing)?SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: _msg,
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32 *1.0),
                )):SizedBox(),

          ],
        ));
  }
}
