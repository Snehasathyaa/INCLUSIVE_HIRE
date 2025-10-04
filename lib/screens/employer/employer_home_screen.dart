import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';
import '../role_selection_screen.dart';
import 'posted_jobs_screen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final Color themeColor = Colors.teal[700]!;
  List jobs = [];

  // employer profile values
  int? employerId;
  String companyName = "";
  String email = "";
  String phone = "";
  String location = "";

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchEmployerProfile();
  }

  /// Load email from SharedPreferences then fetch employer profile
  Future<void> _loadEmailAndFetchEmployerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString("employer_email") ?? "";

    if (savedEmail.isNotEmpty) {
      _fetchEmployerProfile(savedEmail);
    } else {
      print("No employer email found in SharedPreferences.");
    }
  }

  /// Fetch employer details from backend
  Future<void> _fetchEmployerProfile(String emailParam) async {
    final url = Uri.parse(baseUrl+
        "get/email/$emailParam");

    print("Fetching employer profile from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == 1) {
          final employer = data["data"];

          setState(() {
            employerId = employer["id"];
            companyName = employer["company_name"] ?? "";
            email = employer["email"] ?? "";
            phone = employer["phone"] ?? "";
            location = employer["location"] ?? "";
          });

          // Save employer_id in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt("employer_id", employerId!);

          print("Fetched Employer:");
          print("ID: $employerId");
          print("Company: $companyName");
          print("Email: $email");
        } else {
          print("Employer not found: ${data["message"]}");
        }
      } else {
        print("Failed to fetch employer: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching employer: $e");
    }
  }

  /// Post job to backend
  Future<void> postJob() async {
    final prefs = await SharedPreferences.getInstance();
    int employerId = prefs.getInt("employer_id") ?? 0;

    if (employerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employer ID not found. Please re-login")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl+"createJob"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "employer_id": employerId,
        "title": titleController.text,
        "description": descriptionController.text,
        "location": locationController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job posted successfully")),
      );
      titleController.clear();
      descriptionController.clear();
      locationController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to post job")),
      );
    }
  }

  /// Show post job dialog
  void showPostJobDialog() {
    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        floatingLabelStyle: TextStyle(
          color: themeColor,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      );
    }

    showDialog(
      context: context,
      builder: (_) => Center(
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Post a Job",
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: buildInputDecoration("Job Title"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: buildInputDecoration("Description"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: buildInputDecoration("Location"),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: themeColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            postJob();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                          ),
                          child: const Text(
                            "Post",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.white,
    
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: themeColor),
              child: Text(
                companyName.isEmpty ? "Employer Menu" : companyName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Colors.teal),
              title: const Text("Posted Jobs"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostedJobsScreen()),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.people, color: Colors.teal),
            //   title: const Text("Applied Candidates"),
            //   onTap: () {
            //     if (jobs.isNotEmpty) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               AppliedCandidatesScreen(jobId: jobs[0]["id"].toString()),
            //         ),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //             content: Text("No jobs available to view applicants")),
            //       );
            //     }
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.logout, color: themeColor),
              title: const Text("Logout"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RoleSelectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             // const SizedBox(height: 4), // small gap from AppBar
              Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Welcome Text
              Text(
                "Welcome, $companyName  👋",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 35), // reduced gap
              // Motivational Quote
              Text(
                "“Great opportunities don’t happen. You create them.”",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 108),
              Text(
                "Post your first job using the button below!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showPostJobDialog,
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
