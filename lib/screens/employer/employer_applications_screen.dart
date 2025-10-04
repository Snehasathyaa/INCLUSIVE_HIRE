import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  State<EmployerApplicationsScreen> createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen> {
  List applications = [];
  final Color themeColor = Colors.teal[700]!;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    final prefs = await SharedPreferences.getInstance();
    int employerId = prefs.getInt("employer_id") ?? 1;

    final response = await http.get(Uri.parse(baseUrl+"employerApplications/$employerId"));
    if (response.statusCode == 200) {
      setState(() {
        applications = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Applications"), backgroundColor: themeColor),
      
      body: applications.isEmpty
          ? Center(child: Text("No applications yet"))
          : ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${app["seeker_name"]} applied for ${app["title"]}"),
                    subtitle: Text("Email: ${app["email"]}\nStatus: ${app["status"]}"),
                  ),
                );
              },
            ),
    );
  }
}
