import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';
import 'employer/employer_home_screen.dart';

class OTPLoginScreenEmp extends StatefulWidget {
  final String companyName, email, phone,  location;
  const OTPLoginScreenEmp({super.key, required this.companyName, required this.email, required this.phone, required this.location});

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreenEmp> {
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

  /// ✅ API: Send OTP
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
        Uri.parse(baseUrl+"send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          otpSent = true;
          isLoading = false;
          startCountdown();
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP sent to $email")));
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// ✅ API: Verify OTP
  Future<void> verifyOtp() async {
    final email = widget.email.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(baseUrl+"verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        setState(() => isLoading = false);
        sendtoservero();
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  Future<void> sendtoservero() async {
     final prefs = await SharedPreferences.getInstance();

    
    try {
      final response = await http.post(
        Uri.parse(baseUrl+"empregistration"),
        headers: {
            "Content-Type": "application/json",  // 👈 JSON header
},
        body: 
    jsonEncode(
        {
          "company_name": widget.companyName,
          "email": widget.email,
          "phone": widget.phone,
          "location": widget.location,
        },
      )
      );

      final data = json.decode(response.body);

      if (data["success"].toString() == "1") {
        // ✅ Save to SharedPreferences
        await prefs.setString("employer_company", widget.companyName);
        await prefs.setString("employer_email", widget.email);
        await prefs.setString("employer_phone", widget.phone);
        await prefs.setString("employer_location", widget.location);
        await prefs.setString("role", "employer");
        await prefs.setString("isloged", "yes");

        if (data["employer_id"] != null) {
          await prefs.setString("employer_id", data["employer_id"].toString());
        }


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(" ${data["message"]}")),
        );

        // ✅ Navigate to Employer Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmployerHomeScreen(
            
          )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(" ${data["message"]}")),

        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                      ? Text( "Sending OTP to ${widget.email}...",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700]))
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
                              child: const Text("Verify OTP",
                                  style: TextStyle(color: Colors.white)),
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
