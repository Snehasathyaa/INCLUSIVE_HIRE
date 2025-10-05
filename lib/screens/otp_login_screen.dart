import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class OTPLoginScreen extends StatefulWidget {
  final String name, email, phone, skills, location, disability;
  final File? resumeFile;
  const OTPLoginScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.skills,
    required this.location,
    required this.disability,
    required this.resumeFile,
  });

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final TextEditingController otpController = TextEditingController();

  bool otpSent = false;
  bool isLoading = false;
  int countdown = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  ///  Send OTP
  Future<void> sendOtp() async {
    final email = widget.email.trim();
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

  ///  Verify OTP
  Future<void> verifyOtp() async {
    final email = widget.email.trim();
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
        setState(() => isLoading = false);
        sendtoservero();
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

  Future<void> sendtoservero() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", widget.name);
    await prefs.setString("email", widget.email);
    await prefs.setString("disability", widget.disability);
    await prefs.setString("skills", widget.skills);
    await prefs.setString("location", widget.location);
    await prefs.setString("phone", widget.phone);
    await prefs.setString("isloged", "yes");
    await prefs.setString("role", "user");

    try {
      var uri = Uri.parse(baseUrl + "registerprofile");

      var request = http.MultipartRequest("POST", uri);

      // Add fields
      request.fields['name'] = widget.name;
      request.fields['email'] = widget.email;
      request.fields['disability'] = widget.disability;
      request.fields['skills'] = widget.skills;
      request.fields['location'] = widget.location;
      request.fields['phone'] = widget.phone;

      // Add file (assuming widget.resumefile is a File object)
      if (widget.resumeFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('resume', widget.resumeFile!.path),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final resp = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp["message"] ?? "Unknown error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
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
                      ? Text(
                          "Sending OTP to ${widget.email}...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
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
