import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_setup_screen.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({super.key});

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;
  bool isLoading = false;
  int countdown = 0;
  Timer? timer;

  Future<void> verifyPhone({bool isResend = false}) async {
    setState(() {
      isLoading = true;
      if (!isResend) otpSent = false;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text.trim()}",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        navigateToProfile();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          otpSent = true;
          isLoading = false;
          startCountdown();
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        setState(() => isLoading = false);
      },
    );
  }

  Future<void> verifyOTP() async {
    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text,
      );
      await _auth.signInWithCredential(credential);
      navigateToProfile();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  void navigateToProfile() {
    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSetupScreen(
          userPhone: phoneController.text,
        ),
      ),
    );
  }

  void startCountdown() {
    countdown = 60;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
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
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                            SizedBox(height: 40),
                            SizedBox(
                              width: 280,
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration:
                                    inputDecoration("Enter Phone Number"),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: verifyPhone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: borderColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: Size(180, 50),
                              ),
                              child: Text("Send OTP",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 20),
                            SizedBox(
                              width: 280,
                              child: TextField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: inputDecoration("Enter OTP"),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: verifyOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: borderColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: Size(180, 50),
                              ),
                              child: Text("Verify OTP",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(height: 20),
                            countdown > 0
                                ? Text(
                                    "Resend OTP in $countdown sec",
                                    style: TextStyle(color: Colors.grey[700]),
                                  )
                                : TextButton(
                                    onPressed: () =>
                                        verifyPhone(isResend: true),
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
