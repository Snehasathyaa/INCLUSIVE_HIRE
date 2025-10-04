import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool isApplying = false;
  bool applied = false;

  final Color themeColor = Colors.teal[700]!;

  Future<void> applyForJob() async {
    setState(() {
      isApplying = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString("email") ?? "";

      if (userEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User email not found. Please login again.")),
        );
        setState(() => isApplying = false);
        return;
      }

      final response = await http.post(
        Uri.parse("http://192.168.20.12:4000/api/users/apply"), // backend API
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_email": userEmail,
          "job_id": widget.job["job_id"],
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["success"] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Applied successfully!")),
        );
        setState(() {
          applied = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Failed to apply.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isApplying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Job Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(
    color: Colors.white, // <-- change the back arrow color here
  ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job["title"] ?? "",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        widget.job["company_name"] ?? "",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        widget.job["job_location"] ?? "",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Job Description Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 6))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: themeColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Job Description",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.job["description"] ?? "No description available.",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Floating Apply Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (applied || isApplying) ? null : () => applyForJob(),
        backgroundColor: applied ? Colors.grey : themeColor,
        label: Text(
          applied ? "Applied" : (isApplying ? "Applying..." : "Apply Now"),
          style: const TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.send, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
