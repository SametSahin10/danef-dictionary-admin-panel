import 'package:danef_dictionary_admin_panel/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'injection_container.dart' as di;

void main() async {
  // di stands for dependency injection
  di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danef Dictionary Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      home: SignInScreen(),
    );
  }
}
