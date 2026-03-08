import 'package:flutter/material.dart';
import 'package:flutter_firebase_mastery_2023/component/button.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:flutter_firebase_mastery_2023/component/switchauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_alert/awesome_alert.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController? controllerUsername = TextEditingController();
  TextEditingController? controllerEmail = TextEditingController();
  TextEditingController? controllerPassword = TextEditingController();
  TextEditingController? controllerConfirmPassword = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 50),
                    alignment: Alignment.center,
                    width: 70,
                    height: 70,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    // height: 200,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Sign up",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Please sign up to create an account.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Form(
                  key: formstate,
                  child: Column(
                    children: [
                      FormInput(
                        label: "Username",
                        hintText: "Enter your username",
                        controller: controllerUsername,
                      ),
                      FormInput(
                        label: "Email",
                        hintText: "Enter your email",
                        controller: controllerEmail,
                      ),
                      FormInput(
                        label: "Password",
                        hintText: "Enter your password",
                        controller: controllerPassword,
                        obscureText: true,
                      ),
                      FormInput(
                        label: "Confirm Password",
                        hintText: "Confirm your password",
                        controller: controllerConfirmPassword,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "The Confirm Password field is required";
                          }
                          if (value != controllerPassword!.text) {
                            return "Passwords do not match!";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                if (_loading) Center(child: CircularProgressIndicator()),
                Button(
                  label: "Sign Up",
                  onPressed: () async {
                    if (formstate.currentState!.validate()) {
                      formstate.currentState!.save();
                      try {
                        _loading = true;
                        setState(() {});
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: controllerEmail!.text.trim(),
                              password: controllerPassword!.text,
                            );
                        _loading = false;
                        setState(() {});
                        if (FirebaseAuth.instance.currentUser!.emailVerified ==
                            false) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: 'Verify Email',
                            desc:
                                'A verification email has been sent to ${controllerEmail!.text.trim()}. Please check your inbox (and spam folder).',
                            btnCancelOnPress: () async {
                              _loading = true;
                              setState(() {});
                              await FirebaseAuth.instance.signOut();
                              _loading = false;
                              setState(() {});
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                "signup",
                                (route) => false,
                              );
                            },
                            btnOkOnPress: () async {
                              try {
                                _loading = true;
                                setState(() {});
                                await FirebaseAuth.instance.currentUser!
                                    .sendEmailVerification();
                                _loading = false;
                                setState(() {});
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  "verifyemail",
                                  (route) => false,
                                );
                              } catch (e) {
                                _loading = false;
                                setState(() {});
                                AwesomeAlert.show(
                                  context,
                                  title: "Error",
                                  description:
                                      "Failed to send verification email: $e",
                                  confirmText: "Ok",
                                  confirmAction: () =>
                                      Navigator.of(context).pop(),
                                );
                              }
                              return;
                            },
                          ).show();
                        } else {
                          Navigator.pushReplacementNamed(context, "home");
                        }
                      } on FirebaseAuthException catch (e) {
                        _loading = false;
                        setState(() {});
                        if (e.code == 'weak-password') {
                          AwesomeAlert.show(
                            context,
                            title: "Error",
                            description: "The password provided is too weak.",
                            confirmText: "Ok!",
                            confirmAction: () => Navigator.of(context).pop(),
                          );
                        } else if (e.code == 'email-already-in-use') {
                          AwesomeAlert.show(
                            context,
                            title: "Error",
                            description:
                                "The account already exists for that email.",
                            confirmText: "Ok!",
                            confirmAction: () => Navigator.of(context).pop(),
                          );
                        } else {
                          AwesomeAlert.show(
                            context,
                            title: "Error",
                            description:
                                "An error occurred [${e.code}]: ${e.message}",
                            confirmText: "Ok!",
                            confirmAction: () => Navigator.of(context).pop(),
                          );
                        }
                      } catch (e) {
                        _loading = false;
                        setState(() {});
                        print(e);
                        AwesomeAlert.show(
                          context,
                          title: "Error",
                          description: "An unexpected error occurred: $e",
                          confirmText: "Ok!",
                          confirmAction: () => Navigator.of(context).pop(),
                        );
                      }
                    } //if
                  }, //onPressed
                ),
                Switchauth(login: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
