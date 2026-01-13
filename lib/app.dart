import 'package:flutter/material.dart';
import 'core/user_role.dart';
import './auth/login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // call me to authentucante , emp id
  // role api call

  // TEMP: Replace with auth / API / local storage
  UserRole get _userRole => UserRole.admin; // or UserRole.user

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenGears',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
    );
  }
}
