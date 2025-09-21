import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inclusivehire/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userPhone;
  const ProfileSetupScreen({super.key, required this.userPhone});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String disabilityType = "";
  final List<String> disabilityOptions = [
    "Hearing Impairment",
    "Mobility Impairment",
    "Cognitive Disability",
    "Other",
  ];

  Future<void> saveProfileToServer() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", nameController.text);
    await prefs.setString("email", emailController.text);
    await prefs.setString("disability", disabilityType);
    await prefs.setString("skills", skillsController.text);
    await prefs.setString("location", locationController.text);
    await prefs.setString("phone", widget.userPhone);

    try {
      var uri = Uri.parse(
        "http://192.168.20.11:8080/InclusiveHire/saveProfile.jsp",
      );
      var response = await http.post(
        uri,
        body: {
          'name': nameController.text,
          'email': emailController.text,
          'disability': disabilityType,
          'skills': skillsController.text,
          'location': locationController.text,
          'phone': widget.userPhone,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Profile saved successfully")));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save profile. Status: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal;

    InputDecoration buildInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
      );
    }

    return Scaffold(
      backgroundColor: Colors.teal[50],
      // appBar: AppBar(
      //   title: Text("Profile Setup"),
      //   backgroundColor: primaryColor,
      //   elevation: 2,
      // ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: Colors.teal.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Complete Your Profile",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: buildInputDecoration("Full Name", Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? "Enter name" : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration:
                            buildInputDecoration("Email Address", Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter email";
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(value)) return "Enter valid email";
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: disabilityOptions.contains(disabilityType)
                            ? disabilityType
                            : null,
                        decoration: InputDecoration(
                          labelText: "Disability Type",
                          floatingLabelStyle: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.accessibility, color: primaryColor),
                        ),
                        hint: Text("Select Disability Type"),
                        onChanged: (val) => setState(() => disabilityType = val!),
                        items: disabilityOptions
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Select disability type" : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: skillsController,
                        decoration: buildInputDecoration("Skills", Icons.build),
                        validator: (value) =>
                            value!.isEmpty ? "Enter skills" : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: locationController,
                        decoration:
                            buildInputDecoration("Location", Icons.location_on),
                        validator: (value) =>
                            value!.isEmpty ? "Enter location" : null,
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: saveProfileToServer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Save Profile",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
