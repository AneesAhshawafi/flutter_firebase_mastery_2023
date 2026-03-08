import 'package:flutter/material.dart';

class Switchauth extends StatelessWidget {
  final bool? login;
  final VoidCallback? onGooglePressed;

  const Switchauth({super.key, required this.login, this.onGooglePressed});
  @override
  @override
  Widget build(BuildContext context) {
    String? labelHead;
    String? labelSub;
    String? checkAccount;
    String? route;
    if (login == true) {
      labelHead = "login";
      checkAccount = "Don't have an account?";
      labelSub = "Sign up";
      route = "signup";
    } else {
      labelHead = "Sign up";
      checkAccount = "Already have an account?";
      labelSub = "Login";
      route = "login";
    }
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Center(
            child: Text(
              "ــــــــــــــــــــــ or $labelHead with ــــــــــــــــــــــ",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {},
                child: Icon(Icons.apple, size: 65),
              ),
              MaterialButton(
                onPressed: onGooglePressed?? (){},
                child: Image.asset(
                  "images/google_720255.png",
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                checkAccount,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                    Navigator.pushReplacementNamed(context, route!);
                 
                },
                child: Text(
                  labelSub,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
