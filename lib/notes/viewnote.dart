import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/notes/addnote.dart';

class ViewNote extends StatefulWidget {
  final String noteId;
  final String categoryId;
  const ViewNote({super.key, required this.categoryId, required this.noteId});
  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  bool _loading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  DocumentSnapshot? noteData;
  int currentIndex = 0;
  TextEditingController editNoteTextController = TextEditingController();

  @override
  void initState() {
    // getData();
    super.initState();
  }

  @override
  void dispose() {
    editNoteTextController.dispose();
    super.dispose();
  }

  // getData() async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //       .collection('categories')
  //       .doc(widget.categoryId)
  //       .collection("notes")
  //       .doc(widget.noteId)
  //       .get();
  //   noteData = documentSnapshot;
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          //header
          children: [Expanded(child: Text("Current Note"))],
        ),
      ),
      key: scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (val) {
          setState(() {
            currentIndex = val;
          });
        },
        // fixedColor:Colors.blue,
        backgroundColor: const Color.fromARGB(255, 252, 249, 249),
        iconSize: 30.0,
        selectedItemColor: const Color.fromARGB(255, 140, 64, 255),
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          color: const Color.fromARGB(255, 140, 64, 255),
        ),
        unselectedLabelStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "ـــ"),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: "ـــ"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "ـــ"),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection("notes")
            .doc(widget.noteId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Note not found or deleted"));
          }
          final noteMap = snapshot.data!.data() as Map<String, dynamic>;
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Divider(color: Colors.black),
                Text(
                  "Your Note",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.bottomSlide,
                                      title: "Warning!",
                                      desc:
                                          "Are you really want to delete this note?",
                                      btnOkText: "confirm!",
                                      btnOkOnPress: () async {
                                        setState(() {
                                          _loading = true;
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('categories')
                                            .doc(widget.categoryId)
                                            .collection("notes")
                                            .doc(widget.noteId)
                                            .delete();
                                        if (mounted) {
                                          setState(() {
                                            _loading = false;
                                          });
                                          Navigator.of(
                                            context,
                                          ).pop(); // Back to notes list
                                        }
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    size: 25,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    editNoteTextController.text =
                                        noteMap["note"] ?? "";
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.noHeader,
                                      animType: AnimType.bottomSlide,
                                      title: "Edit Note",
                                      body: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Edit Note",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                              controller:
                                                  editNoteTextController,
                                              autofocus: true,
                                              maxLines:
                                                  null, // Allow multiple lines
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Note Content",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      btnOkText: "Save",
                                      btnOkOnPress: () async {
                                        if (editNoteTextController.text
                                            .trim()
                                            .isNotEmpty) {
                                          await FirebaseFirestore.instance
                                              .collection('categories')
                                              .doc(widget.categoryId)
                                              .collection("notes")
                                              .doc(widget.noteId)
                                              .update({
                                                'note': editNoteTextController
                                                    .text
                                                    .trim(),
                                              });
                                        }
                                      },
                                      btnCancelText: "Cancel",
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 25,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey[400]),
                          SizedBox(height: 10),
                          Expanded(
                            child: Container(
                              width:double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  noteMap["note"] ?? "",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
