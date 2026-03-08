import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class addNote extends StatefulWidget {
  final String docId;
  const addNote({super.key, required this.docId});

  @override
  State<addNote> createState() => _addNoteState();
}

class _addNoteState extends State<addNote> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController noteController = TextEditingController();
  bool? _loading = false;
  @override
  dispose() {
    noteController.dispose();
    super.dispose();
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
        .add({'note': noteController.text})
        .then((value) {
          setState(() {
            _loading = false;
          });
          // AwesomeDialog(
          //   context: context,
          //   title: "Success",
          //   btnOkText: "OK",
          //   btnOkOnPress: () {
          //     noteController.clear();
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
          noteController.clear();
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
            Form(
              key: formKey,
              child: Column(
                children: [
                  FormInput(
                    label: "Note Title",
                    hintText: "Enter Your Note",
                    controller: noteController,
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
          ],
        ),
      ),
    );
  }
}
