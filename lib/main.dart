import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_delivery_person_app/provider/auth_provider.dart';
import 'package:grocery_delivery_person_app/screens/home_screen.dart';
import 'package:grocery_delivery_person_app/screens/login_screen.dart';
import 'package:grocery_delivery_person_app/screens/registration_screen.dart';
import 'package:grocery_delivery_person_app/screens/reset_password_screen.dart';
import 'package:grocery_delivery_person_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDKNSapKXYrTKL4xD5cXSnmn5ppC8KDVgc",
      appId: "1:147156304764:android:9b8e799300149943da9af9",
      messagingSenderId: "147156304764",
      projectId: "grocery-application-3329d",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ListenableProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        ResetPasswordScreen.id: (context) => const ResetPasswordScreen(),
      },
    );
  }
}