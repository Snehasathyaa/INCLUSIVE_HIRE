import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/const.dart';
import 'package:http/http.dart' as http;

import '../pdf_viewer.dart';

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

    try {
      final uri = Uri.parse(
        baseUrl + "getApplicants/${int.tryParse(widget.jobId)}",
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          applicants = decoded["data"] ?? [];
        });
      } else {
        print(
          "Failed to fetch applicants. Status code: ${response.statusCode}",
        );
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate["phone"] ?? "No phone"),
                        Text(candidate["email"] ?? ""),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.description, color: Colors.grey),
                      onPressed: () {
                        String path = fileUrl + candidate["resume"];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewPage(path: path),
                          ),
                        );

                        print("Open Resume: ${candidate["resume"]}");
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
