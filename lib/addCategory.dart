import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  bool? _loading = false;
  @override
  dispose() {
    nameController.dispose();
    super.dispose();
  }

  CollectionReference categories = FirebaseFirestore.instance.collection(
    'categories',
  );

  Future<void> addCategory() {
    // Call the user's CollectionReference to add a new user
    setState(() {
      _loading = true;
    });
    return categories
        .add({
          'name': nameController.text,
          "id": FirebaseAuth.instance.currentUser!.uid,
        })
        .then((value) {
          setState(() {
            _loading = false;
          });
          AwesomeDialog(
            context: context,
            title: "Success",
            btnOkText: "OK",
            btnOkOnPress: () {
              nameController.clear();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "home",
                (route) => false,
              );
              // Navigator.pop(context);
            },
            body: Text("Category Added"),
            dialogType: DialogType.success,
          ).show();
        })
        .catchError((error) {
          setState(() {
            _loading = false;
          });
          AwesomeDialog(
            context: context,
            title: "Error",
            body: Text("Failed to add category"),
            dialogType: DialogType.error,
          ).show();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Category")),
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
                    label: "Category Name",
                    hintText: "Enter Category Name",
                    controller: nameController,
                  ),
                  if (_loading == true) CircularProgressIndicator(),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        addCategory();
                      }
                    },
                    child: Text("Add Category"),
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
