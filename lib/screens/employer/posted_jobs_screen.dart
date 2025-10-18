import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import 'applied_candidates_screen.dart';

class PostedJobsScreen extends StatefulWidget {
  const PostedJobsScreen({super.key});

  @override
  State<PostedJobsScreen> createState() => _PostedJobsScreenState();
}

class _PostedJobsScreenState extends State<PostedJobsScreen> {
  List jobs = [];
  final Color themeColor = Colors.teal[700]!;
  String? employerId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployerIdAndFetchJobs();
  }

  Future<void> _loadEmployerIdAndFetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.get("employer_id");

    if (storedId is int) {
      employerId = storedId.toString();
    } else if (storedId is String) {
      employerId = storedId;
    }

    if (employerId != null) {
      await fetchJobs();
    }
  }

  Future<void> fetchJobs() async {
    if (employerId == null) return;
    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(baseUrl + "getjobs/$employerId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jobsData = decoded["data"] ?? [];

        setState(() {
          jobs = jobsData;
        });
      } else {
        print("Failed to fetch jobs. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteJob(String jobId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this job?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel",style: TextStyle(
              color:themeColor,
            ))  ,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",style: TextStyle(
              color: Colors.white,
            ),),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse(baseUrl + "deletejob"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"job_id": jobId}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == 1) {
          setState(() {
            jobs.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Job deleted successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(decoded["message"] ?? "Delete failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error while deleting")),
        );
      }
    } catch (e) {
      print("Error deleting job: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    }
  }

  Future<void> _refreshJobs() async {
    await fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Jobs Posted", style: TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
        color: themeColor,
        child: isLoading && jobs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : jobs.isEmpty
                ? ListView(
                    shrinkWrap: true,
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          "No jobs posted yet.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final jobId = (job["_id"] ?? job["id"] ?? "").toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            job["title"]?.toString() ?? "No Title",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: themeColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                job["description"]?.toString() ?? "",
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: themeColor, size: 18),
                                  const SizedBox(width: 4),
                                  Text(job["location"]?.toString() ?? "Unknown"),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.people, color: themeColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AppliedCandidatesScreen(jobId: jobId),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.grey),
                                    onPressed: () => _deleteJob(jobId, index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
