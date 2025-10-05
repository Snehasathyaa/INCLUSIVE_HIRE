import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/employer/employer_home_screen.dart';
import 'package:hire_inclusive/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';
import 'role_selection_screen.dart';

class loginpage extends StatefulWidget {
  final int type;
  const loginpage({super.key, required this.type});

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<loginpage> {
  final TextEditingController otpController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  bool otpSent = false;
  bool isLoading = false;
  int countdown = 0;
  Timer? timer;

  /// API: Send OTP
  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email address")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(baseUrl + "send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        setState(() {
          otpSent = true;
          isLoading = false;
          startCountdown();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("OTP sent to $email")));
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter OTP")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(baseUrl + "verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        ///  OTP verified → now check login in DB
        await loginWithType(email);
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> loginWithType(String email) async {
    try {
      // Assume you already know the type from role_selection_screen
      // type = 0 for user, 1 for employer
      final prefs = await SharedPreferences.getInstance();
      final int type = widget.type;

      final response = await http.post(
        Uri.parse(baseUrl + "login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "type": type}),
      );

      setState(() => isLoading = false);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == 1) {
          final profile = data["data"];

          if (type == 0) {
            /// Save user data
            await prefs.setString("name", profile["name"]);
            await prefs.setString("email", profile["email"]);
            await prefs.setString("disability", profile["disability"]);
            await prefs.setString("skills", profile["skills"]);
            await prefs.setString("location", profile["location"]);
            await prefs.setString("phone", profile["phone"]);
            await prefs.setString("role", "user");
            await prefs.setString("isloged", "yes");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            /// Save employer data
            await prefs.setString("employer_company", profile["company_name"]);
            await prefs.setString("employer_email", profile["email"]);
            await prefs.setString("employer_phone", profile["phone"]);
            await prefs.setString("employer_location", profile["location"]);
            await prefs.setString("role", "employer");
            await prefs.setString("isloged", "yes");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmployerHomeScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You are not registered")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
          );
          //  Navigator.pop(context); // Go back to previous page
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("You are not registered")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// Timer for resend OTP
  void startCountdown() {
    countdown = 60;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.teal[700]!;

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        floatingLabelStyle: TextStyle(color: borderColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: borderColor))
            : Center(
                child: SingleChildScrollView(
                  child: otpSent == false
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Welcome to Inclusive Hire App",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: borderColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: 280,
                              child: TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: inputDecoration(
                                  "Enter Email Address",
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: borderColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(180, 50),
                              ),
                              child: const Text(
                                "Send OTP",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 280,
                              child: TextField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: inputDecoration("Enter OTP"),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: borderColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(180, 50),
                              ),
                              child: const Text(
                                "Verify OTP",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),
                            countdown > 0
                                ? Text(
                                    "Resend OTP in $countdown sec",
                                    style: TextStyle(color: Colors.grey[700]),
                                  )
                                : TextButton(
                                    onPressed: sendOtp,
                                    child: Text(
                                      "Resend OTP",
                                      style: TextStyle(color: borderColor),
                                    ),
                                  ),
                          ],
                        ),
                ),
              ),
      ),
    );
  }
}
