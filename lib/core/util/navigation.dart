import 'package:danef_dictionary_admin_panel/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

void pushDashboardScreen(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => DashboardScreen()),
    (route) => false,
  );
}

void pushSignInScreen(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => SignInScreen()),
    (route) => false,
  );
}
