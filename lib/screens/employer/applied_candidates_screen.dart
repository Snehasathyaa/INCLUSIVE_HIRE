// lib/screens/employer/applied_candidates_screen.dart

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppliedCandidatesScreen extends StatefulWidget {
  final String jobId;

  const AppliedCandidatesScreen({super.key, required this.jobId});

  @override
  State<AppliedCandidatesScreen> createState() =>
      _AppliedCandidatesScreenState();
}

class _AppliedCandidatesScreenState extends State<AppliedCandidatesScreen> {
  List applicants = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchApplicants();
  }

  Future<void> fetchApplicants() async {
    setState(() => isLoading = true);




log("wi-------"+widget.jobId);
    try {
      final uri = Uri.parse(
          "http://192.168.20.12:4000/api/users/getApplicants/${int.tryParse(widget.jobId)}");
      final response = await http.get(uri);



      log("respppppp=-------"+response.body);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          applicants = decoded["data"] ?? [];
        });
      } else {
        print("Failed to fetch applicants. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching applicants: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Applied Candidates")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applicants.isEmpty
              ? const Center(child: Text("No candidates applied yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: applicants.length,
                  itemBuilder: (context, index) {
                    final candidate = applicants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.teal),
                        title: Text(candidate["name"] ?? "Unknown"),
                        subtitle: Text(candidate["email"] ?? ""),
                        trailing: IconButton(
                          icon: const Icon(Icons.description,
                              color: Colors.grey),
                          onPressed: () {
                            print("Open Resume: ${candidate["resume"]}");
                            // TODO: Open resume file or URL
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
