import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_firebase_mastery_2023/addCategory.dart';
import 'package:flutter_firebase_mastery_2023/auth/login.dart';
import 'package:flutter_firebase_mastery_2023/auth/signup.dart';
import 'package:flutter_firebase_mastery_2023/home.dart';
import 'package:flutter_firebase_mastery_2023/auth/verifyemail.dart';
import 'package:flutter_firebase_mastery_2023/core/theme/app_theme.dart';
import 'package:flutter_firebase_mastery_2023/core/utils/app_logger.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before anything else
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.i('Firebase initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const Home();
          }
          return const Login();
        },
      ),
      routes: {
        'login': (context) => const Login(),
        'signup': (context) => const SignUp(),
        'home': (context) => const Home(),
        'verifyemail': (context) => const Verifyemail(),
        'addCategory': (context) => const AddCategory(),
      },
    );
  }
}
