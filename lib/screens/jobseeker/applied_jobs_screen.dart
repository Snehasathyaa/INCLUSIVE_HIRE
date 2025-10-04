// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User email not found.")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.20.12:4000/api/users/applied/$userEmail"),
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
          SnackBar(content: Text(data["message"] ?? "Failed to fetch applied jobs.")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.teal[700]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Applications", style: TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(
    color: Colors.white, // <-- change the back arrow color here
  ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(job["title"] ?? ""),
                            subtitle: Text("${job["company_name"] ?? ""} • ${job["job_location"] ?? ""}"),
                            //trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(job: job),
                                ),
                              );
                            },
                          ),
                          if (job["description"] != null && job["description"].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                              child: Text(
                                job["description"],
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
