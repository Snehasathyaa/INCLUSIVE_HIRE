import 'package:flutter/material.dart';
import 'employer/employer_registration_screen.dart';
import 'profile_setup_screen.dart';
class RoleSelectionScreen extends StatelessWidget {
  // final String useremail;
   const RoleSelectionScreen({super.key, });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Choose Your Role",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileSetupScreen(type: 0)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("I am a Job Seeker",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EmployerRegistrationScreen(type: 1)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("I am an Employer",
                    style: TextStyle(color: Colors.white)),
              ),
           
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'employer/employer_registration.dart';
// import 'profile_setup_screen.dart';

// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key});

//   Future<void> saveRole(String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("role", role);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final borderColor = Colors.teal;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F5),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 await saveRole("jobseeker");
//                 Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) =>
//                             const ProfileSetupScreen(userPhone: "")));
//               },
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: borderColor, minimumSize: const Size(200, 50)),
//               child: const Text("I am a Job Seeker",
//                   style: TextStyle(color: Colors.white)),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 await saveRole("employer");
//                 Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const EmployerRegistrationScreen()));
//               },
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: borderColor, minimumSize: const Size(200, 50)),
//               child: const Text("I am an Employer",
//                   style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// // import 'package:flutter/material.dart';
// // import 'profile_setup_screen.dart';
// // import 'employer/employer_registration_screen.dart';

// // class RoleSelectionScreen extends StatelessWidget {
// //   const RoleSelectionScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF0F2F5),
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Text("Select Your Role",
// //                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
// //               const SizedBox(height: 40),
// //               ElevatedButton(
// //                 onPressed: () => Navigator.push(
// //                   context,
// //                   MaterialPageRoute(builder: (_) => const ProfileSetupScreen(userPhone: "1234567890")),
// //                 ),
// //                 style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50), backgroundColor: Colors.teal),
// //                 child: const Text("Job Seeker", style: TextStyle(color: Colors.white)),
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: () => Navigator.push(
// //                   context,
// //                   MaterialPageRoute(builder: (_) => const EmployerRegistrationScreen()),
// //                 ),
// //                 style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50), backgroundColor: Colors.teal),
// //                 child: const Text("Employer", style: TextStyle(color: Colors.white)),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
