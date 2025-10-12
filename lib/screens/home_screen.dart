import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'const.dart';
import 'jobseeker/applied_jobs_screen.dart';
import 'jobseeker/job_detail_screen.dart';
import 'jobseeker/profile_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color themeColor = Colors.teal[700]!;
  List jobs = [];
  List filteredJobs = []; // filtered list for search

  String username = "Loading..", email = "Loading..";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch jobs from backend
  Future<void> fetchJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse(baseUrl + "getalljob"));

      print("API Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          jobs = data["data"];
          filteredJobs = jobs; // initialize filteredJobs
          email = prefs.getString("email") ?? "";
          username = prefs.getString("name") ?? "User";
        });
      } else {
        print("Failed to fetch jobs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }

  // Filter jobs by search query
  void filterJobs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredJobs = jobs.where((job) {
        final title = (job["title"] ?? "").toLowerCase();
        final location = (job["job_location"] ?? "").toLowerCase();
        return title.contains(lowerQuery) || location.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int maxLength = screenWidth < 400
        ? 80
        : screenWidth < 600
            ? 120
            : 160;

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
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFFF0F2F5),
                child: Text(
                  username.isNotEmpty ? username[0] : "U",
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
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoleSelectionScreen(),
                  ),
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
              "👋 $username ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            TextField(
              controller: searchController,
              onChanged: filterJobs,
              decoration: InputDecoration(
                hintText: "Search by title or location",
                prefixIcon: Icon(Icons.search, color: themeColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Job Listings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredJobs.isEmpty
                  ? const Center(
                      child: Text(
                        "No jobs available right now.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
                                if (job["description"] != null &&
                                    job["description"].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      job["description"].length > maxLength
                                          ? "${job["description"].substring(0, maxLength)}..."
                                          : job["description"],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: themeColor,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JobDetailsScreen(job: job),
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
