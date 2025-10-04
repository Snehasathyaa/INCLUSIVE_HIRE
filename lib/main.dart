import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/role_selection_screen.dart';
import 'package:hire_inclusive/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'screens/home_screen.dart';
import 'screens/employer/employer_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final phone = prefs.getString("phone");
  final role = prefs.getString("role");

  Widget startScreen;
  if (phone != null && role != null) {
    if (role == "jobseeker") {
      startScreen = HomeScreen();
    } else {
      startScreen = EmployerHomeScreen();
    }
  } else {
    startScreen = RoleSelectionScreen();
  }

  runApp(InclusiveHireApp(startScreen: startScreen));
}

class InclusiveHireApp extends StatelessWidget {
  final Widget startScreen;
  const InclusiveHireApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inclusive Hire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: SplashScreen(),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'screens/profile_setup_screen.dart';

// //import 'screens/otp_login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//    runApp(const InclusiveHireApp());
// }

// class InclusiveHireApp extends StatelessWidget {
//   const InclusiveHireApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Inclusive Hire',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//      // home:  SplashScreen(),
//      home: ProfileSetupScreen(userPhone: ''),
//     );
//   }
// }
