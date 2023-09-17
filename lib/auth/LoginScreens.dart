import 'dart:convert';
import 'dart:io';

import 'package:chatmanager/Screens/Homepage.dart';
import 'package:chatmanager/screens/PopupmenuScreens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_calling_code_picker/country.dart';
import 'package:country_calling_code_picker/country_code_picker.dart';
import 'package:country_calling_code_picker/functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({Key? key}) : super(key: key);

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  ImagePicker picker = ImagePicker();
  File? selectedimage;
  bool isload = false;
  String _selectedCountry = "india";
  void _showCountryPicker() async {
    List<Country> list = await getCountries(context);
    final country = await showCountryPickerDialog(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country as String;
      });
    }
  }

  static List<CountryModel> _dropdownItems = [];
  final formKey = new GlobalKey<FormState>();

  TextEditingController numbercontroller = TextEditingController();
  CountryModel? _dropdownValue;
  String? _errorText;
  TextEditingController phoneController = new TextEditingController();
  TextEditingController _name = new TextEditingController();
  File ?selected;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _dropdownItems.add(CountryModel(country: 'India', countryCode: '+91'));
      _dropdownItems.add(CountryModel(country: 'USA', countryCode: '+1'));
      _dropdownValue = _dropdownItems[0];
      phoneController.text = _dropdownValue!.countryCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildProfilepic(),
            _buildCountry(),
            _buildPhonefiled(),
            ElevatedButton(
                onPressed: () async {
                  var code = phoneController.text.toString();
                  var number = numbercontroller.text.toString();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("numbercontroller", number);
                  await FirebaseFirestore.instance.collection("number").add({
                    "numbercontroller": number,
                    "phoneController": code,
                  }).then(
                    (document) async {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0),
                            ),
                          ),
                          builder: (context) {
                            return SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    top: 15.0,
                                    right: 15.0,
                                    left: 15.0),
                                child: SizedBox(
                                  height: 200.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Enter your name",
                                          style: TextStyle(fontSize: 15.0)),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              maxLength: 20,
                                              controller: _name,
                                              keyboardType: TextInputType.name,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                              onPressed: () {},
                                              child: Text("Cancel")),
                                          TextButton(
                                              onPressed: () async {
                                                var name =
                                                    _name.text.toString();
                                                var uuid = Uuid();
                                                var filename = uuid.v1();
                                                await FirebaseStorage.instance.ref(filename).putFile(selectedimage!).
                                                whenComplete((){}).then((filedata) async{
                                                  await filedata.ref.getDownloadURL().then((fileurl) async{
                                                    await FirebaseFirestore.instance
                                                        .collection("name")
                                                        .where("name",
                                                        isEqualTo: name)
                                                        .get()
                                                        .then((documents) async {
                                                      if (documents.size <= 0) {
                                                        FirebaseFirestore.instance
                                                            .collection("name")
                                                            .add({
                                                          "name": name,
                                                          "fileurl":fileurl,
                                                          "filename":filename
                                                        }).then((documentid) async{
                                                          print(documentid);
                                                          SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          prefs.setString("name", name);
                                                          prefs.setString(
                                                              "senderid",
                                                              documentid.id
                                                                  .toString());
                                                          print("sid========="+documentid.id
                                                              .toString());
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PopupmenuScreens(),
                                                              ));
                                                        });
                                                      } else {
                                                        SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                        prefs.setString("name", name);
                                                        prefs.setString(
                                                            "senderid",
                                                            documents
                                                                .docs.first.id
                                                                .toString());
                                                        print("sid================"+document.id
                                                            .toString());
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PopupmenuScreens(),
                                                            ));
                                                      }
                                                    });
                                                  });
                                                });
                                                // await FirebaseFirestore.instance
                                                //     .collection("name")
                                                //   .where("name",
                                                //           isEqualTo: name)
                                                //       .get()
                                                //       .then((documents) async {
                                                //     if (documents.size <= 0) {
                                                //       FirebaseFirestore.instance
                                                //           .collection("name")
                                                //           .add({
                                                //         "name": name,
                                                //       }).then((documentid) async{
                                                //         print(documentid);
                                                //         SharedPreferences prefs =
                                                //             await SharedPreferences
                                                //             .getInstance();
                                                //         prefs.setString("name", name);
                                                //         prefs.setString(
                                                //             "senderid",
                                                //             documentid.id
                                                //                 .toString());
                                                //         print("sid========="+documentid.id
                                                //             .toString());
                                                //         Navigator.of(context)
                                                //             .pushReplacement(
                                                //                 MaterialPageRoute(
                                                //           builder: (context) =>
                                                //               PopupmenuScreens(),
                                                //         ));
                                                //       });
                                                //     } else {
                                                //       SharedPreferences prefs =
                                                //           await SharedPreferences
                                                //           .getInstance();
                                                //       prefs.setString("name", name);
                                                //       prefs.setString(
                                                //           "senderid",
                                                //           documents
                                                //               .docs.first.id
                                                //               .toString());
                                                //       print("sid================"+document.id
                                                //           .toString());
                                                //       Navigator.of(context)
                                                //           .pushReplacement(
                                                //               MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             PopupmenuScreens(),
                                                //       ));
                                                //     }
                                                //   });
                                              },



                                              child: Text("Save")),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  );
                },
                child: Text("Next"))
          ],
        ),
      ),
    );
  }

  Widget _buildCountry() {
    return FormField(
      builder: (FormFieldState state) {
        return DropdownButtonHideUnderline(
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new InputDecorator(
                  decoration: InputDecoration(
                    filled: false,
                    hintText: 'Choose Country',
                    prefixIcon: Icon(Icons.location_on),
                    labelText:
                        _dropdownValue == null ? 'Where are you from' : 'From',
                    errorText: _errorText,
                  ),
                  isEmpty: _dropdownValue == null,
                  child: new DropdownButton(
                    value: _dropdownValue,
                    isDense: true,
                    onChanged: (newValue) {
                      setState(() {
                        _dropdownValue = newValue;
                        phoneController.text = _dropdownValue!.countryCode;
                      });
                    },
                    items: _dropdownItems.map((CountryModel value) {
                      return DropdownMenuItem<CountryModel>(
                        value: value,
                        child: Text(value.country),
                      );
                    }).toList(),
                  ),
                ),
              ]),
        );
      },
    );
  }

  Widget _buildPhonefiled() {
    return Row(
      children: <Widget>[
        new Expanded(
          child: new TextFormField(
            controller: phoneController,
            enabled: false,
            decoration: InputDecoration(
              filled: false,
              prefixIcon: Icon(Icons.abc),
              labelText: 'code',
              hintText: "Country code",
            ),
          ),
          flex: 2,
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: numbercontroller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: false,
              labelText: 'mobile',
              hintText: "Mobile number",
              prefixIcon: new Icon(Icons.mobile_screen_share),
            ),
            onSaved: (value) {},
          ),
          flex: 5,
        ),
      ],
    );
  }
  Widget _buildProfilepic() {
    return Center(
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Align(
          alignment: Alignment.bottomRight,
          child: CircleAvatar(
            backgroundColor: Colors.greenAccent.shade200,
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
                                IconButton(onPressed: () async{
                                  XFile? photo = await picker.pickImage(source: ImageSource.camera);
                                  setState(() {
                                    selectedimage = File(photo!.path);
                                  });
                                }, icon: Icon(Icons.photo),),
                                Text("Camera"),
                              ],
                            ),
                            SizedBox(width: 20.0,),
                            Column(
                              children: [
                                IconButton(onPressed: () async{
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  setState(() {
                                    selectedimage = File(image!.path);

                                  });
                                }, icon: Icon(Icons.browse_gallery),),
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
        backgroundImage: (selectedimage==null)?AssetImage(
            'img/concierge.png') as ImageProvider:
        FileImage(File(selectedimage?.path ?? '')),
      ),
    );
  }
}




class CountryModel {
  String country = '';

  String countryCode = '';

  CountryModel({
    required this.country,
    required this.countryCode,
  });
}
