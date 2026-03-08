import 'package:flutter/material.dart';
import 'package:flutter_firebase_mastery_2023/component/button.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:flutter_firebase_mastery_2023/component/switchauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_alert/awesome_alert.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController? controllerEmail = TextEditingController();
  TextEditingController? controllerPassword = TextEditingController();
  bool? status = false;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    // استبدل القيمة بـ Web Client ID من Firebase Console
    GoogleSignIn.instance.initialize(
      serverClientId:
          '895746574423-nk1p5nq2408rlf99sfaf2tvs62lmm6k7.apps.googleusercontent.com',
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      _loading = true;
      setState(() {});

      // Firebase handles the entire Google OAuth flow internally
      await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());

      _loading = false;
      setState(() {});

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      _loading = false;
      setState(() {});
      // Ignore user cancellation
      if (e.code != 'ERROR_ABORTED_BY_USER' && context.mounted) {
        AwesomeAlert.show(
          context,
          title: "Error",
          description: "Google Sign-In failed: ${e.message}",
          confirmText: "Ok",
          confirmAction: () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      _loading = false;
      setState(() {});
      if (context.mounted) {
        AwesomeAlert.show(
          context,
          title: "Error",
          description: "An unexpected error occurred: $e",
          confirmText: "Ok",
          confirmAction: () => Navigator.of(context).pop(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
                    "Login",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Please login to your account.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

                Form(
                  // autovalidateMode: AutovalidateMode.always,
                  key: formstate,
                  child: Column(
                    children: [
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
                      Padding(
                        padding: EdgeInsets.only(left: 40, right: 20, top: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Remember me",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Checkbox(
                                  value: status,
                                  onChanged: (value) {
                                    setState(() {
                                      status = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                if (controllerEmail!.text.isEmpty) {
                                  AwesomeAlert.show(
                                    context,
                                    title: "Error",
                                    description: "Please enter your email",
                                    confirmText: "Ok",
                                    confirmAction: () =>
                                        Navigator.of(context).pop(),
                                  );
                                  return;
                                }
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                        email: controllerEmail!.text,
                                      );
                                  AwesomeAlert.show(
                                    context,
                                    title: "Success",
                                    description:
                                        "Password reset email sent,check your email to reset your password.",
                                    confirmText: "Ok",
                                    confirmAction: () =>
                                        Navigator.of(context).pop(),
                                  );
                                } catch (e) {
                                  AwesomeAlert.show(
                                    context,
                                    title: "Error",
                                    description:
                                        "Failed to send password reset email,check your email and try again.",
                                    confirmText: "Ok",
                                    confirmAction: () =>
                                        Navigator.of(context).pop(),
                                  );
                                }
                              },
                              child: Text(
                                "Forgot password?",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading) Center(child: CircularProgressIndicator()),
                      Button(
                        label: "Login",
                        onPressed: () async {
                          if (formstate.currentState!.validate()) {
                            formstate.currentState!.save();
                            try {
                              _loading = true;
                              setState(() {});
                              final credential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                    email: controllerEmail!.text,
                                    password: controllerPassword!.text,
                                  );
                              setState(() {
                                _loading = false;
                              });
                              if (FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .emailVerified ==
                                  false) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.rightSlide,
                                  title: 'Error',
                                  desc: 'Please verify your email',
                                  btnCancelOnPress: () async {
                                    _loading = true;
                                    setState(() {});
                                    await FirebaseAuth.instance.signOut();
                                    _loading = false;
                                    setState(() {});
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      "login",
                                      (route) => false,
                                    );
                                  },
                                  btnOkOnPress: () async {
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
                                    return;
                                  },
                                ).show();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Logged in successfully!"),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      81,
                                      76,
                                      175,
                                    ),
                                  ),
                                );

                                Navigator.pushReplacementNamed(context, "home");
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'invalid-credential') {
                                AwesomeAlert.show(
                                  context,
                                  title: "Error",
                                  description: "Wrong Email or Password!",
                                  confirmText: "Ok!",
                                  confirmAction: () =>
                                      Navigator.of(context).pop(),
                                );
                                print('No user found for that email.');
                              } else if (e.code == 'network-request-failed') {
                                AwesomeAlert.show(
                                  context,
                                  title: "Error",
                                  description: "No internet connection!",
                                  confirmText: "Ok!",
                                  confirmAction: () =>
                                      Navigator.of(context).pop(),
                                );
                              } else {
                                AwesomeAlert.show(
                                  context,
                                  title: "Error",
                                  description:
                                      "An error occurred [${e.code}]: ${e.message}",
                                  confirmText: "Ok!",
                                  confirmAction: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              }
                              setState(() {
                                _loading = false;
                              });
                            }
                          } else {
                            print("Not Validated");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Switchauth(
                  login: true,
                  onGooglePressed: () {
                    signInWithGoogle();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
