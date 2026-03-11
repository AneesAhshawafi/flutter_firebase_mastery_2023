import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';

class ViewNote extends StatefulWidget {
  final String noteId;
  final String categoryId;
  const ViewNote({super.key, required this.categoryId, required this.noteId});
  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  DocumentSnapshot? noteData;
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editContentController = TextEditingController();

  @override
  void dispose() {
    _editTitleController.dispose();
    _editContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
      ),
      key: _scaffoldKey,
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
                                Expanded(
                                  // widthFactor: double.infinity,
                                  child: Text(
                                    noteMap["title"] ?? "Your Note",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.bottomSlide,
                                      title: "Warning!",
                                      desc:
                                          "Are you really want to delete this note?",
                                      btnOkText: 'Delete',
                                      btnOkOnPress: () async {
                                        await FirebaseFirestore.instance
                                            .collection('categories')
                                            .doc(widget.categoryId)
                                            .collection('notes')
                                            .doc(widget.noteId)
                                            .delete();
                                        if (mounted) Navigator.of(context).pop();
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
                                    _editTitleController.text =
                                        noteMap["title"] ?? "";
                                    _editContentController.text =
                                        noteMap["content"] ?? "";
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
                                            FormInput(
                                              label: "Note Title",
                                              hintText: "Enter Your Note Title",
                                              controller:
                                                  _editTitleController,
                                            ),
                                            FormInput(
                                              label: "Note Content",
                                              hintText:
                                                  "Enter Your Note Content",
                                              controller:
                                                  _editContentController,
                                              maxLines: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      btnOkText: "Save",
                                      btnOkOnPress: () async {
                                        if (_editTitleController.text
                                            .trim()
                                            .isNotEmpty) {
                                          await FirebaseFirestore.instance
                                              .collection('categories')
                                              .doc(widget.categoryId)
                                              .collection("notes")
                                              .doc(widget.noteId)
                                              .update({
                                                'title':
                                                    _editTitleController
                                                        .text
                                                        .trim(),
                                                'content':
                                                    _editContentController
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
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                // decoration: BoxDecoration(
                                //   border: Border.all(color: Colors.grey),
                                // ),
                                child: Text(
                                  noteMap["content"] ?? "Empty Note",
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
