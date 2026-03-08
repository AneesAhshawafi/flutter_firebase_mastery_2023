import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/component/button.dart';

class Verifyemail extends StatefulWidget {
  const Verifyemail({super.key});

  @override
  State<Verifyemail> createState() => _VerifyemailState();
}

class _VerifyemailState extends State<Verifyemail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Please verify your email"),
              SizedBox(height: 20),
              Button(
                label: "Resend email verification",
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.currentUser!
                        .sendEmailVerification();
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Success',
                      desc:
                          'Verification email link sent, please check your emailbox',
                      btnOkOnPress: () {},
                    ).show();
                  } catch (e) {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Error',
                      desc: e.toString(),
                      btnOkOnPress: () {},
                    ).show();
                  }
                },
              ),
              SizedBox(height: 20),
              Button(
                label: "Confirm Verification",
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser!.reload();
                  if (FirebaseAuth.instance.currentUser!.emailVerified) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "home",
                      (route) => false,
                    );
                  } else {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Error',
                      btnCancelText: "Go to login",
                      desc: 'Please verify your email first from your mailbox',
                      btnOkOnPress: () {},
                      btnCancelOnPress: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "login",
                          (route) => false,
                        );
                      },
                    ).show();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
