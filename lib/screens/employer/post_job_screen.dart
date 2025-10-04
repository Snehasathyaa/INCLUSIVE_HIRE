import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../const.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final Color themeColor = Colors.teal[700]!;

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse(baseUrl+"postjob");

    try {
      final response = await http.post(url, body: {
        "title": titleController.text,
        "description": descriptionController.text,
        "location": locationController.text,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job posted successfully!")),
        );
        Navigator.pop(context); // Go back to Employer Dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error posting job")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post a Job"),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(
    color: Colors.white, // <-- change the back arrow color here
  ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Job Title"),
                validator: (v) => v!.isEmpty ? "Enter job title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (v) => v!.isEmpty ? "Enter location" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _postJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Post Job", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
