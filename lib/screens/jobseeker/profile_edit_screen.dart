import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  /// Load profile from SharedPreferences
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString("name") ?? "";
      emailController.text = prefs.getString("email") ?? "";
      phoneController.text = prefs.getString("phone") ?? "";
      skillsController.text = prefs.getString("skills") ?? "";
      locationController.text = prefs.getString("location") ?? "";
      disabilityType = prefs.getString("disability") ?? "";
      resumePath = prefs.getString("resume");
      isLoading = false;
    });
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

  /// Save profile to SharedPreferences
  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (disabilityType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select disability type")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", nameController.text);
    await prefs.setString("email", emailController.text);
    await prefs.setString("phone", phoneController.text);
    await prefs.setString("skills", skillsController.text);
    await prefs.setString("location", locationController.text);
    await prefs.setString("disability", disabilityType);
    if (resumePath != null) await prefs.setString("resume", resumePath!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    final themeColor = Colors.teal;
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: TextStyle(
        color: themeColor,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
         iconTheme: const IconThemeData(
          color: Colors.white, 
         ),
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
                      decoration: buildInputDecoration("Full Name", Icons.person),
                      validator: (value) => value!.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: buildInputDecoration("Phone", Icons.phone),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter phone number";
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) return "Enter valid 10-digit phone";
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
                      value: disabilityOptions.contains(disabilityType) ? disabilityType : null,
                      decoration: buildInputDecoration("Disability", Icons.accessibility),
                      onChanged: (val) => setState(() => disabilityType = val!),
                      items: disabilityOptions
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Select disability" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: skillsController,
                      decoration: buildInputDecoration("Skills", Icons.build),
                      validator: (value) => value!.isEmpty ? "Enter skills" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: buildInputDecoration("Location", Icons.location_on),
                      validator: (value) => value!.isEmpty ? "Enter location" : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: pickResume,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.upload_file, color: Colors.teal),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                resumePath != null
                                    ? resumePath!.split('/').last
                                    : "Upload Resume (PDF/DOC/DOCX)",
                                style: TextStyle(
                                  color: resumePath != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
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
                        child: const Text(
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
