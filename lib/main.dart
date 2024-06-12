import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smarthome_final/firebase_options.dart';
import 'package:smarthome_final/page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAnVZSgMGwNM9E4C6OoKNtP2O-ynZB5o8E",
            authDomain: "vsl-final.firebaseapp.com",
            databaseURL: "https://vsl-final-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "vsl-final",
            storageBucket: "vsl-final.appspot.com",
            messagingSenderId: "108877943104",
            appId: "1:108877943104:web:58e1dff1913f5886ee6aa5",
            measurementId: "G-WTG9FZ2GWM"
        )
    );
  }
  else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
