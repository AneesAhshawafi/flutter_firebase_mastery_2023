import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:flutter_firebase_mastery_2023/notes/addnote.dart';
import 'package:flutter_firebase_mastery_2023/notes/viewnote.dart';

class Notes extends StatefulWidget {
  final String categoryId;
  const Notes({super.key, required this.categoryId});
  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  bool _loading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<QueryDocumentSnapshot> notes = [];
  int currentIndex = 0;
  TextEditingController editNoteTitleTextController = TextEditingController();
  TextEditingController editNoteContentTextController = TextEditingController();

  @override
  void initState() {
    // getData();
    super.initState();
  }

  @override
  void dispose() {
    editNoteTitleTextController.dispose();
    editNoteContentTextController.dispose();
    super.dispose();
  }

  // getData() async {
  //   notes.clear();
  //   setState(() {
  //     _loading = true;
  //   });
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('categories')
  //       .doc(widget.categoryId)
  //       .collection("notes")
  //       .get();
  //   notes.addAll(querySnapshot.docs);
  //   setState(() {
  //     _loading = false;
  //   });
  //   // querySnapshot.docs.forEach((doc) {
  //   //     print(doc["Title"]);
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        height: 150,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "noteAddBtn",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => addNote(docId: widget.categoryId),
                    ),
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
            FloatingActionButton(
              heroTag: "noteRefreshBtn",
              onPressed: () {
                // Navigator.pushTitledAndRemoveUntil(
                //   context,
                //   "home",
                //   (route) => false,
                // );
              },
              child: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Expanded(child: Text("Notes List")),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearch(notes: notes),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection("notes")
            .snapshots(),
        builder: (context, snapshot) {
          // جاري التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          this.notes = snapshot.data!.docs; // ← تتحدث تلقائياً
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Divider(color: Colors.black),
                Text(
                  "Notes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Expanded(
                  child: notes.isEmpty
                      ? Center(child: Text("Empty Folder"))
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                // mainAxisSpacing: 10,
                                // crossAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ViewNote(
                                      categoryId: widget.categoryId,
                                      noteId: notes[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                AwesomeDialog(
                                                  context: context,
                                                  dialogType:
                                                      DialogType.warning,
                                                  animType:
                                                      AnimType.bottomSlide,
                                                  title: "Warning!",
                                                  desc:
                                                      "Are you really want to delete this note?",
                                                  btnOkText: "confifrm!",
                                                  btnOkOnPress: () async {
                                                    _loading = true;
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                          'categories',
                                                        )
                                                        .doc(widget.categoryId)
                                                        .collection("notes")
                                                        .doc(notes[index].id)
                                                        .delete();
                                                    // Navigator.pushReplacementTitled(
                                                    //   context,
                                                    //   "home",
                                                    // );
                                                    // getData();
                                                    _loading = false;
                                                  },
                                                  btnCancelOnPress: () {},
                                                ).show();
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            InkWell(
                                              onTap: () {
                                                editNoteTitleTextController
                                                        .text =
                                                    notes[index]["title"];
                                                editNoteContentTextController
                                                        .text =
                                                    notes[index]["content"];
                                                AwesomeDialog(
                                                  context: context,
                                                  dialogType:
                                                      DialogType.noHeader,
                                                  animType:
                                                      AnimType.bottomSlide,
                                                  title: "ReTitle Note",
                                                  body: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "ReTitle Note",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 12),
                                                        FormInput(
                                                          label: "Note Title",
                                                          hintText: "Enter Your Note Title",
                                                          controller: editNoteTitleTextController,
                                                        ),
                                                        FormInput(
                                                          label: "Note Content",
                                                          hintText: "Enter Your Note Content",
                                                          controller: editNoteContentTextController,
                                                          maxLines: 10,
                                                        ),
                                                        // TextField(
                                                        //   style: TextStyle(
                                                        //     fontSize: 15,
                                                        //     fontWeight:
                                                        //         FontWeight.w500,
                                                        //     color: Colors.black,
                                                        //   ),
                                                        //   controller:
                                                        //       editNoteTitleTextController,
                                                        //   autofocus: true,
                                                        //   decoration:
                                                        //       InputDecoration(
                                                        //         border:
                                                        //             OutlineInputBorder(),
                                                        //         labelText:
                                                        //             "New Title",
                                                        //       ),
                                                        // ),
                                                        // TextField(
                                                        //   style: TextStyle(
                                                        //     fontSize: 15,
                                                        //     fontWeight:
                                                        //         FontWeight.w500,
                                                        //     color: Colors.black,
                                                        //   ),
                                                        //   controller:
                                                        //       editNoteContentTextController,
                                                        //   autofocus: true,
                                                        //   decoration: InputDecoration(
                                                        //     border:
                                                        //         OutlineInputBorder(),
                                                        //     labelText:
                                                        //         "New Content",
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  btnOkText: "Save",
                                                  btnOkOnPress: () async {
                                                    if (editNoteTitleTextController
                                                        .text
                                                        .trim()
                                                        .isNotEmpty) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                            'categories',
                                                          )
                                                          .doc(
                                                            widget.categoryId,
                                                          )
                                                          .collection("notes")
                                                          .doc(notes[index].id)
                                                          .update({
                                                            'Title':
                                                                editNoteTitleTextController
                                                                    .text
                                                                    .trim(),
                                                            'content':
                                                                editNoteContentTextController
                                                                    .text
                                                                    .trim(),
                                                          });
                                                      // .set({
                                                      //   'Title': editNoteTitleTextController.text
                                                      //       .trim(),
                                                      // },SetOptions(merge: true)
                                                      // );

                                                      // getData();
                                                    }
                                                  },
                                                  btnCancelText: "Cancel",
                                                  btnCancelOnPress: () {},
                                                ).show();
                                              },
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        // width:double.infinity,
                                        // height:100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                notes[index]["title"] ??
                                                    "No Title",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueAccent[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Expanded(
                                              child: Text(
                                                notes[index]["content"] ??
                                                    "No Content",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[800],
                                                  height: 1.3,
                                                ),
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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

class CustomSearch extends SearchDelegate {
  final List<QueryDocumentSnapshot> notes;

  CustomSearch({required this.notes});

  List<QueryDocumentSnapshot>? filterList;
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          print(query);
          query = "";
          // Navigator.of(context).pushReplacementTitled("searchdelegate");
        },
        icon: Icon(Icons.close),
      ),
      // IconButton(onPressed: (){}, icon: Icon(Icons.close)),
      // IconButton(onPressed: (){}, icon: Icon(Icons.close)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        // Navigator.of(context).pushReplacementTitled("searchdelegate");
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (filterList == null || filterList!.isEmpty) {
      if (query.isEmpty) {
        return Center(child: Text("Search for a note"));
      } else {
        return Center(child: Text("No results found"));
      }
    }

    return ListView.builder(
      itemCount: filterList!.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ViewNote(
                  categoryId: filterList![index].reference.parent.parent!.id,
                  noteId: filterList![index].id,
                ),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                filterList![index]["note"],
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == "") {
      return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              query = notes[index]["note"];
              showResults(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  notes[index]["note"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        },
      );
    } else {
      filterList = notes
          .where(
            (element) => element["note"].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
      return ListView.builder(
        itemCount: filterList!.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              query = filterList![index]["note"];
              showResults(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  filterList![index]["note"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
