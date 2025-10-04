import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hire_inclusive/screens/const.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../pdf_viewer.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String disabilityType = "";
  String? resumePath;

  final List<String> disabilityOptions = [
    "Hearing Impairment",
    "Mobility Impairment",
    "Cognitive Disability",
    "Other",
  ];

  bool isLoading = true;
  bool upload = false;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    skillsController.dispose();
    locationController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email") ?? "";
    final url = Uri.parse(
      baseUrl+"getprofile/$email",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          nameController.text = data["data"]["name"] ?? "";
          emailController.text = data["data"]["email"] ?? "";
          phoneController.text = data["data"]["phone"] ?? "";
          skillsController.text = data["data"]["skills"] ?? "";
          locationController.text = data["data"]["location"] ?? "";
          disabilityType = data["data"]["disability"] ?? "";
          resumePath = data["data"]["resume"] ?? "";
          isLoading = false;
        });
      } else {
        print("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  /// Pick resume file from phone storage
  Future<void> pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          resumePath = result.files.single.path;
        });
        print("Picked Resume: $resumePath");
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to pick resume. Please try again."),
        ),
      );
    }
  }

 Future<void> updateProfile() async {
  if (!_formKey.currentState!.validate()) return;

  if (disabilityType.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select disability type")),
    );
    return;
  }
  setState(() {
    upload =true;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email") ?? "";

    var uri = Uri.parse(baseUrl+"updateprofile/$email");
    var request = http.MultipartRequest("PUT", uri);

    // Add form fields
    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['skills'] = skillsController.text;
    request.fields['location'] = locationController.text;
    request.fields['disability'] = disabilityType;

    // Add resume file if user selected a new one
if (resumePath != null && resumePath!.contains("/")) {
  // contains "/" → it's a real local file path
  request.files.add(await http.MultipartFile.fromPath("resume", resumePath!));
}


    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    print("Update Status: ${responseBody.statusCode}");
    print("Update Response: ${responseBody.body}");

    if (responseBody.statusCode == 200) {
      final resp = jsonDecode(responseBody.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp["message"] ?? "Profile updated")),
      );

      // Save updated data locally
      await prefs.setString("name", nameController.text);
      await prefs.setString("phone", phoneController.text);
      await prefs.setString("skills", skillsController.text);
      await prefs.setString("location", locationController.text);
      await prefs.setString("disability", disabilityType);
      if (resp["data"]["resume"] != null) {
        await prefs.setString("resume", resp["data"]["resume"]);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${responseBody.body}")),
      );
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error updating profile: $e")),
    );
  }finally {
    setState(() {
      upload = false;
    });
  }
}


  InputDecoration buildInputDecoration(String label, IconData icon) {
    final themeColor = Colors.teal;
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: TextStyle(
        color: themeColor,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: themeColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: themeColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon, color: themeColor),
    );
  }

  String get resumeDisplayName {
  if (resumePath == null) return "Upload Resume (PDF/DOC/DOCX)";
  if (resumePath!.contains('/')) return resumePath!.split('/').last;
  return resumePath!; // just filename from API
}


String get resumeUrl {
  if (resumePath == null || resumePath!.isEmpty) return "";
  if (resumePath!.startsWith("http")) return resumePath!;
  // If it's just a filename from DB
  if (!resumePath!.contains("/")) return fileUrl + resumePath!;
  // Else it's a picked local file
  return resumePath!;
}



Future<void> openResume() async {
  if (resumePath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No resume uploaded")),
    );
    return;
  }

  // Determine actual path or URL
  String path = resumeUrl;

  log("path-------"+path);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewPage(path: path),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: nameController,
                      decoration: buildInputDecoration(
                        "Full Name",
                        Icons.person,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: buildInputDecoration("Phone", Icons.phone),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Enter phone number";
                        if (!RegExp(r'^\d{10}$').hasMatch(value))
                          return "Enter valid 10-digit phone";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      readOnly: true,
                      decoration: buildInputDecoration("Email", Icons.email),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: disabilityOptions.contains(disabilityType)
                          ? disabilityType
                          : null,
                      decoration: buildInputDecoration(
                        "Disability",
                        Icons.accessibility,
                      ),
                      onChanged: (val) => setState(() => disabilityType = val!),
                      items: disabilityOptions
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      validator: (value) => value == null || value.isEmpty
                          ? "Select disability"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: skillsController,
                      decoration: buildInputDecoration("Skills", Icons.build),
                      validator: (value) =>
                          value!.isEmpty ? "Enter skills" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: buildInputDecoration(
                        "Location",
                        Icons.location_on,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter location" : null,
                    ),
                    const SizedBox(height: 16),
                  InkWell(
  onTap: pickResume,
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.teal.withOpacity(0.5),
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.upload_file, color: Colors.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            resumeDisplayName,
            style: TextStyle(
              color: resumePath != null ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
        if (resumePath != null) ...[
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.teal),
            onPressed: openResume,
          ),
        ],
      ],
    ),
  ),
),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: upload ? Center(child: const CircularProgressIndicator()) : Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
