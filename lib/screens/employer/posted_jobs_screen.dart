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
                              Icon(
                                Icons.location_on,
                                color: themeColor,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(job["location"]?.toString() ?? "Unknown"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final jobId = (job["_id"] ?? job["id"] ?? "")
                                      .toString();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AppliedCandidatesScreen(jobId: jobId),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.people,
                                  color: Colors.grey,
                                  size: 20,
                                ),
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
