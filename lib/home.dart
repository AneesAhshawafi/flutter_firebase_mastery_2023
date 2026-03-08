import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_mastery_2023/details.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/notes/notes.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    // getData();
    super.initState();
  }

  // getData() async {
  //   categories.clear();
  //   setState(() {
  //     _loading = true;
  //   });
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('categories')
  //       .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //       .get();
  //   categories.addAll(querySnapshot.docs);
  //   setState(() {
  //     _loading = false;
  //   });
  //   // querySnapshot.docs.forEach((doc) {
  //   //     print(doc["name"]);
  //   // });
  // }

  @override
  void dispose() {
    print(" home page dispose");
    super.dispose();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<QueryDocumentSnapshot> categories = [];
  int currentIndex = 0;
  TextEditingController editController = TextEditingController();
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
                  Navigator.pushNamed(context, "addCategory");
                },
                child: Icon(Icons.add),
              ),
            ),
            FloatingActionButton(
              heroTag: "noteRefreshBtn",
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "home",
                  (route) => false,
                );
              },
              child: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearch(categories: categories),
              );
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 30,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "login",
                (route) => false,
              );
            },
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
            .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // جاري التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          this.categories = snapshot.data!.docs; // ← تتحدث تلقائياً
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Divider(color: Colors.black),
                Text(
                  "Categories",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      // mainAxisSpacing: 10,
                      // crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  Notes(categoryId: categories[index].id),
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
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          animType: AnimType.bottomSlide,
                                          title: "Warning!",
                                          desc:
                                              "Are you really want to delete this folder?",
                                          btnOkText: "confifrm!",
                                          btnOkOnPress: () async {
                                            _loading = true;
                                            FirebaseFirestore.instance
                                                .collection('categories')
                                                .doc(categories[index].id)
                                                .delete();
                                            // Navigator.pushReplacementNamed(
                                            //   context,
                                            //   "home",
                                            // );
                                            // getData();
                                            _loading = false;
                                          },
                                          btnCancelOnPress: () {},
                                        ).show();
                                      },
                                      child: Icon(Icons.delete, size: 20),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        editController.text =
                                            categories[index]["name"];
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.noHeader,
                                          animType: AnimType.bottomSlide,
                                          title: "Rename Category",
                                          body: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Rename Category",
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
                                                  controller: editController,
                                                  autofocus: true,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: "New Name",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          btnOkText: "Save",
                                          btnOkOnPress: () async {
                                            if (editController.text
                                                .trim()
                                                .isNotEmpty) {
                                              await FirebaseFirestore.instance
                                                  .collection('categories')
                                                  .doc(categories[index].id)
                                                  // .set({
                                                  //   'name': editController.text
                                                  //       .trim(),
                                                  // },SetOptions(merge: true)
                                                  // );
                                                  .update({
                                                    'name': editController.text
                                                        .trim(),
                                                  });
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
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  "images/folder.png",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fill,
                                ),
                                // Image.asset("images/google_720255.png", width: 100, height: 100),
                                Text(categories[index]["name"]),
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
  final List<QueryDocumentSnapshot> categories;

  CustomSearch({required this.categories});

  List<QueryDocumentSnapshot>? filterList;
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          print(query);
          query = "";
          // Navigator.of(context).pushReplacementNamed("searchdelegate");
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
        // Navigator.of(context).pushReplacementNamed("searchdelegate");
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (filterList == null || filterList!.isEmpty) {
      if (query.isEmpty) {
        return Center(child: Text("Search for a category"));
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
                builder: (context) => Notes(categoryId: filterList![index].id),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                filterList![index]["name"],
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
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              query = categories[index]["name"];
              showResults(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  categories[index]["name"],
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
      filterList = categories
          .where(
            (element) => element["name"].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
      return ListView.builder(
        itemCount: filterList!.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              query = filterList![index]["name"];
              showResults(context);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  filterList![index]["name"],
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
