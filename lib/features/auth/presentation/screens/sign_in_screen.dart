import 'package:danef_dictionary_admin_panel/core/config/constants.dart';
import 'package:danef_dictionary_admin_panel/core/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/util/actions.dart';
import '../../../../core/util/validators.dart';
import '../../../../injection_container.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../domain/use_cases/sign_in_use_case.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  TextEditingController _emailController;
  TextEditingController _passwordController;

  FocusNode _passwordFocusNode;

  final _emailDecoration = InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(fontSize: 20, color: Colors.green),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.4, color: Colors.green),
      borderRadius: BorderRadius.circular(18),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.4, color: Colors.red),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.4, color: Colors.green),
      borderRadius: BorderRadius.circular(18),
    ),
  );

  final _passwordDecoration = InputDecoration(
    labelText: 'Password',
    labelStyle: TextStyle(fontSize: 20, color: Colors.green),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.4, color: Colors.green),
      borderRadius: BorderRadius.circular(18),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.4, color: Colors.red),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.4, color: Colors.green),
      borderRadius: BorderRadius.circular(18),
    ),
  );

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Center(
              child: Text(
                'Danef Dictionary Admin Panel',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.08,
                    child: TextFormField(
                      validator: emailValidator,
                      autofocus: false,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _emailDecoration,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                      ),
                      onFieldSubmitted: (value) {
                        _passwordFocusNode.requestFocus();
                      },
                      onSaved: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.08,
                    child: TextFormField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _passwordDecoration,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                      ),
                      onSaved: (value) {
                        setState(() {
                          _password = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.35,
                right: screenWidth * 0.35,
                bottom: screenHeight * 0.015,
              ),
              child: Container(
                width: screenWidth * 0.3,
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.006,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onPressed: _handleSignIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showProgressDialog(
          context: context,
          text: "Signing in...",
        );
      });
      _formKey.currentState.save();
      final signInUseCase = sl<SignInUseCase>();
      final jwtToken = await signInUseCase.call(
        UserParams(
          email: _email.trim(),
          password: _password.trim(),
        ),
      );
      if (jwtToken != null) {
        debugPrint("Signed in succesfully");
        // TODO: Use clean architecture.
        await saveTokenInSharedPrefs(jwtToken);
        pushDashboardScreen(context);
      } else {
        debugPrint("Signin in failed");
        // Hide progressDialog
        Navigator.of(context).pop();
        showAlertDialog(
          context: context,
          message: "Signing in failed. Check your email and password.",
          showActions: false,
        );
      }
    }
  }
}

Future<bool> saveTokenInSharedPrefs(String jwtToken) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return await sharedPreferences.setString(
    Constants.jwtTokenString,
    jwtToken,
  );
}
