import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';
import 'job_detail_screen.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  _AppliedJobsScreenState createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  List appliedJobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppliedJobs();
  }

  Future<void> fetchAppliedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString("email") ?? "";

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User email not found.")));
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl + "applied/$userEmail"),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == 1) {
        setState(() {
          appliedJobs = data["data"];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Failed to fetch applied jobs."),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.teal[700]!;

    // 🔹 Adaptive truncation length based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    int maxLength = screenWidth < 400
        ? 80
        : screenWidth < 600
            ? 120
            : 160;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Applications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appliedJobs.isEmpty
              ? const Center(child: Text("No applied jobs found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appliedJobs.length,
                  itemBuilder: (context, index) {
                    final job = appliedJobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(job: job),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job["title"] ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${job["company_name"] ?? ""} • ${job["job_location"] ?? ""}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              if (job["description"] != null &&
                                  job["description"].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
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
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
