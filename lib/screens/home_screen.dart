import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'jobseeker/applied_jobs_screen.dart';
import 'jobseeker/job_detail_screen.dart';
import 'jobseeker/profile_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String email = "";
  String disabilityType = "";
  String skills = "";
  String location = "";

  final Color themeColor = Colors.teal[700]!;

  List jobs = []; // store jobs from API

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchProfile();
    fetchJobs(); // load jobs when screen starts
  }

  // Load email from SharedPreferences and fetch profile
  Future<void> _loadEmailAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "";
    userName = prefs.getString("name") ?? "User";

    if (email.isNotEmpty) {
      _fetchUserProfile(email);
    } else {
      print("No email found in SharedPreferences.");
    }
  }

  // Fetch profile from backend
  Future<void> _fetchUserProfile(String email) async {
    final url = Uri.parse("http://192.168.20.12:4000/api/users/getProfileByEmail/$email");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          userName = data["data"]["name"] ?? "";
          this.email = data["data"]["email"] ?? "";
          disabilityType = data["data"]["disability"] ?? "";
          skills = data["data"]["skills"] ?? "";
          location = data["data"]["location"] ?? "";
        });
      } else {
        print("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Fetch jobs from backend
  Future<void> fetchJobs() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.20.12:4000/api/users/getalljob"));

      print("API Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          jobs = data["data"];
        });
      } else {
        print("Failed to fetch jobs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Inclusive Hire"),
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: themeColor),
              accountName: Text(userName),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFFF0F2F5),
                child: Text(
                  userName.isNotEmpty ? userName[0] : "U",
                  style: TextStyle(fontSize: 24, color: themeColor),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: themeColor),
              title: const Text("Profile"),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.work, color: themeColor),
              title: const Text("Jobs"),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppliedJobsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: themeColor),
              title: const Text("Logout"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // clear all stored values
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "👋 $userName ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Job Listings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: jobs.isEmpty
                  ? const Center(
                      child: Text(
                        "No jobs available right now.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(
                              job["title"] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${job["company_name"] ?? ""} • ${job["job_location"] ?? ""}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                if (job["description"] != null && job["description"].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      job["description"],
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: themeColor),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(job: job),
                                ),
                              );
                            },

                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
