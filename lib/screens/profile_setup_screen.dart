import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hire_inclusive/screens/loginpage.dart';
import 'package:hire_inclusive/screens/otp_login_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final int type;
  const ProfileSetupScreen({super.key, required this.type});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String disabilityType = "";
  final List<String> disabilityOptions = [
    "Hearing Impairment",
    "Mobility Impairment",
    "Cognitive Disability",
    "Other",
  ];

  File? resumeFile;

  Future<void> pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          resumeFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking file: $e")),
      );
    }
  }

  Future<void> saveProfileToServer() async {
    if (!_formKey.currentState!.validate()) return;

    if (disabilityType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a disability type")),
      );
      return;
    }

    if (resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your resume")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPLoginScreen(
          name: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          skills: skillsController.text,
          location: locationController.text,
          disability: disabilityType,
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: const Color(0xFFF0F2F5),
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
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: nameController,
                        decoration:
                            buildInputDecoration("Full Name", Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? "Enter name" : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: phoneController,
                        decoration:
                            buildInputDecoration("Phone Number", Icons.phone),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter phone number";
                          }
                          if (value.length < 10) {
                            return "Enter valid phone number";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration:
                            buildInputDecoration("Email", Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter email";
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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
                            borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.accessibility,
                              color: primaryColor),
                        ),
                        hint: const Text("Select Disability Type"),
                        onChanged: (val) =>
                            setState(() => disabilityType = val!),
                        items: disabilityOptions
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? "Select disability type"
                                : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: skillsController,
                        decoration:
                            buildInputDecoration("Skills", Icons.build),
                        validator: (value) =>
                            value!.isEmpty ? "Enter skills" : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: locationController,
                        decoration: buildInputDecoration(
                            "Location", Icons.location_on),
                        validator: (value) =>
                            value!.isEmpty ? "Enter location" : null,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Upload Resume styled like TextField
                      InkWell(
                        onTap: pickResume,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: primaryColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload_file, color: primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  resumeFile == null
                                      ? "Upload Resume "
                                      : resumeFile!.path.split('/').last,
                                  style: TextStyle(
                                    color: resumeFile == null
                                        ? Colors.black
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                          onPressed: saveProfileToServer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Save Profile",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => loginpage(type: widget.type),
                            ),
                          );
                        },
                        child: Text(
                          "Already a user ? login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
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









// import 'package:flutter/material.dart';
// import 'package:hire_inclusive/screens/loginpage.dart';
// import 'package:hire_inclusive/screens/otp_login_screen.dart';
// class ProfileSetupScreen extends StatefulWidget {
//   final int type;
//   const ProfileSetupScreen({super.key, required this.type});

//   @override
//   _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
// }

// class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController skillsController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();


//   String disabilityType = "";
//   final List<String> disabilityOptions = [
//     "Hearing Impairment",
//     "Mobility Impairment",
//     "Cognitive Disability",
//     "Other",
//   ];

//   Future<void> saveProfileToServer() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (disabilityType.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Select a disability type")),
//       );
//       return;
//     }

//      Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) =>  OTPLoginScreen(name:nameController.text, email:emailController.text, phone:phoneController.text, skills:skillsController.text, location:locationController.text, disability:disabilityType)),
//         );

//     // Save locally
//     // final prefs = await SharedPreferences.getInstance();
//     // await prefs.setString("name", nameController.text);
//     // await prefs.setString("email", emailController.text);
//     // await prefs.setString("disability", disabilityType);
//     // await prefs.setString("skills", skillsController.text);
//     // await prefs.setString("location", locationController.text);
//     // await prefs.setString("phone", phoneController.text);

//     // try {
//     //   var uri = Uri.parse("http://192.168.20.12:4000/api/users/registerprofile");

//     //   var body = {
//     //     'name': nameController.text,
//     //     'email': emailController.text,
//     //     'disability': disabilityType,
//     //     'skills': skillsController.text,
//     //     'location': locationController.text,
//     //     'phone': phoneController.text,
//     //   };

//     //   print("Sending body: $body"); // Debug

//     //   var response = await http.post(
//     //     uri,
//     //     headers: {'Content-Type': 'application/json'}, // Send as JSON
//     //     body: jsonEncode(body),
//     //   );

//     //   print("Response status: ${response.statusCode}");
//     //   print("Response body: ${response.body}");

//     //   if (response.statusCode == 201) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text("Profile saved successfully")),
//     //     );
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(builder: (context) => const JobsListScreen()),
//     //     );
//     //   } else {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(
//     //         content: Text(
//     //           "Failed to save profile. Status: ${response.statusCode}\n${response.body}",
//     //         ),
//     //       ),
//     //     );
//     //   }
//     // } catch (e) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text("Error saving profile: $e")),
//     //   );
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Colors.teal;

//     InputDecoration buildInputDecoration(String label, IconData icon) {
//       return InputDecoration(
//         labelText: label,
//         floatingLabelStyle: TextStyle(
//           color: primaryColor,
//           fontWeight: FontWeight.bold,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: primaryColor, width: 2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         prefixIcon: Icon(icon, color: primaryColor),
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F5),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 500),
//             child: Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 4,
//               shadowColor: const Color(0xFFF0F2F5),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         "Complete Your Profile",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: nameController,
//                         decoration: buildInputDecoration("Full Name", Icons.person),
//                         validator: (value) => value!.isEmpty ? "Enter name" : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: phoneController,
//                         decoration: buildInputDecoration("Phone Number", Icons.phone),
//                         keyboardType: TextInputType.phone,
//                         maxLength: 10,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) return "Enter phone number";
//                           if (value.length < 10) return "Enter valid phone number";
//                           return null;
//                         },
//                       ),
//                       TextFormField(
//                         controller: emailController,
//                         decoration: buildInputDecoration("Email", Icons.email),
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) return "Enter email";
//                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                             return "Enter valid email";
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       DropdownButtonFormField<String>(
//                         value: disabilityOptions.contains(disabilityType)
//                             ? disabilityType
//                             : null,
//                         decoration: InputDecoration(
//                           labelText: "Disability Type",
//                           floatingLabelStyle: TextStyle(
//                             color: primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: primaryColor.withOpacity(0.5)),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: primaryColor, width: 2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           prefixIcon: Icon(Icons.accessibility, color: primaryColor),
//                         ),
//                         hint: const Text("Select Disability Type"),
//                         onChanged: (val) => setState(() => disabilityType = val!),
//                         items: disabilityOptions
//                             .map((type) => DropdownMenuItem(
//                                   value: type,
//                                   child: Text(type),
//                                 ))
//                             .toList(),
//                         validator: (value) =>
//                             value == null || value.isEmpty ? "Select disability type" : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: skillsController,
//                         decoration: buildInputDecoration("Skills", Icons.build),
//                         validator: (value) => value!.isEmpty ? "Enter skills" : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: locationController,
//                         decoration: buildInputDecoration("Location", Icons.location_on),
//                         validator: (value) => value!.isEmpty ? "Enter location" : null,
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: saveProfileToServer,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 2,
//                           ),
//                           child: const Text(
//                             "Save Profile",
//                             style: TextStyle(fontSize: 18, color: Colors.white),
//                           ),
//                         ),
//                       ),
                   
                   
//                       const SizedBox(height: 20),
//               InkWell(
//                 onTap: () {
//                   // Navigate to login screen
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => loginpage(type:widget.type)),
//                   );
//                 },
//                 child: Text("Already a user ? login",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[600])),
//               ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
