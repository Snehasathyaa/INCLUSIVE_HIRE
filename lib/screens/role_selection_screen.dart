import 'package:flutter/material.dart';
import 'employer/employer_registration_screen.dart';
import 'profile_setup_screen.dart';
class RoleSelectionScreen extends StatelessWidget {
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
