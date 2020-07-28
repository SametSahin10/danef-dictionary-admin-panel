import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

void pushDashboardScreen(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => DashboardScreen()),
    (route) => false,
  );
}