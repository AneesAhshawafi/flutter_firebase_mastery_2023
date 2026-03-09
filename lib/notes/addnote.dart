import 'package:flutter/material.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class addNote extends StatefulWidget {
  final String docId;
  const addNote({super.key, required this.docId});

  @override
  State<addNote> createState() => _addNoteState();
}

class _addNoteState extends State<addNote> {
  File? _file;
  final ImagePicker _picker = ImagePicker();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController titleNoteController = TextEditingController();
  TextEditingController contentNoteController = TextEditingController();
  bool? _loading = false;
  @override
  dispose() {
    titleNoteController.dispose();
    contentNoteController.dispose();
    super.dispose();
  }

  Future<void> getImage(ImageSource source) async {
    final XFile? image;
    // Pick an image.
    if (source == ImageSource.gallery) {
      image = await _picker.pickImage(source: source);
    } else {
      // Capture a photo.
      image = await _picker.pickImage(source: source);
    }
    _file = File(image!.path);
    setState(() {});
  }

  Future<void> addNote() {
    CollectionReference notes = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.docId)
        .collection("notes");
    // Call the user's CollectionReference to add a new user
    setState(() {
      _loading = true;
    });
    return notes
        .add({
          'title': titleNoteController.text,
          'content': contentNoteController.text,
        })
        .then((value) {
          setState(() {
            _loading = false;
          });
          // AwesomeDialog(
          //   context: context,
          //   title: "Success",
          //   btnOkText: "OK",
          //   btnOkOnPress: () {
          //     titleNoteController.clear();
          //     Navigator.pop(context);
          //   },
          //   body: Text("Note Added"),
          //   dialogType: DialogType.success,
          // ).show();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              content: Text("Note Added Successfully!"),
            ),
          );
          titleNoteController.clear();
          contentNoteController.clear();
          Navigator.pop(context);
        })
        .catchError((error) {
          setState(() {
            _loading = false;
          });
          AwesomeDialog(
            context: context,
            title: "Error",
            body: Text("Failed to add your note"),
            dialogType: DialogType.error,
          ).show();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Note")),
      body: Container(
        // padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    FormInput(
                      label: "Note Title",
                      hintText: "Enter Your Note Title",
                      controller: titleNoteController,
                    ),
                    SizedBox(height: 10),
                    FormInput(
                      label: "Note Content",
                      hintText: "Enter Your Note Content",
                      controller: contentNoteController,
                      maxLines: 20,
                    ),

                    // TextField(
                    //   style: TextStyle(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w500,
                    //     color: Colors.black,
                    //   ),
                    //   controller: bodytitleNoteController,
                    //   autofocus: true,
                    //   maxLines: null, // Allow multiple lines
                    //   decoration: InputDecoration(
                    //     border: OutlineInputBorder(),
                    //     labelText: "Note Content",
                    //   ),
                    // ),
                    Card(
                      margin: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: _file != null
                            ? Image.file(
                                _file!,
                                height: 150,
                                fit: BoxFit.contain,
                              )
                            : Text("no image"),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          title: "Choose Source",
                          dialogType: DialogType.noHeader,
                          animType: AnimType.bottomSlide,
                          btnOkOnPress: () {},
                          body: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    getImage(ImageSource.camera);
                                  },
                                  icon: Icon(Icons.camera_alt_outlined),
                                ),
                                IconButton(
                                  onPressed: () {
                                    getImage(ImageSource.gallery);
                                  },
                                  icon: Icon(Icons.browse_gallery_outlined),
                                ),
                              ],
                            ),
                          ),
                        ).show();
                      },
                      child: Text("Get Image"),
                    ),

                    if (_loading == true) CircularProgressIndicator(),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          addNote();
                        }
                      },
                      child: Text("Add Note"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
