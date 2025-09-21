import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'otp_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String email = "";
  String disabilityType = "";
  String skills = "";
  String location = "";
  String phone = "";

  final Color themeColor = Colors.teal[700]!;

  List<Map<String, String>> jobListings = [
    {
      "title": "Software Developer",
      "company": "Tech Solutions, Kochi",
      "location": "Remote"
    },
    {
      "title": "Data Entry Operator",
      "company": "Kerala Govt - Disability Dept",
      "location": "Thiruvananthapuram"
    },
    {
      "title": "Graphic Designer",
      "company": "Creative Minds, Calicut",
      "location": "Hybrid"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPhoneAndFetchProfile();
  }

  Future<void> _loadPhoneAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString("phone") ?? "";

    if (phone.isNotEmpty) {
      _fetchUserProfile(phone);
    } else {
      print("No phone number found in SharedPreferences.");
    }
  }

  Future<void> _fetchUserProfile(String phone) async {
    final url = Uri.parse(
        "http://192.168.20.11:8080/InclusiveHire/fetchUser.jsp?phone=$phone");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          userName = data["name"] ?? "User";
          email = data["email"] ?? "email@example.com";
          disabilityType = data["disability"] ?? "Not Set";
          skills = data["skills"] ?? "";
          location = data["location"] ?? "";
        });

        print("Fetched Profile:");
        print("Name: $userName");
        print("Email: $email");
        print("Disability: $disabilityType");
        print("Skills: $skills");
        print("Location: $location");
      } else {
        print("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Inclusive Hire"),
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: themeColor),
              accountName: Text(userName),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFFF0F2F5),
                child: Text(
                  userName.isNotEmpty ? userName[0] : "U",
                  style: TextStyle(fontSize: 24, color: themeColor),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: themeColor),
              title: const Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.work, color: themeColor),
              title: const Text("Jobs"),
              onTap: () {},
            ),
            // ListTile(
            //   leading: Icon(Icons.settings, color: themeColor),
            //   title: const Text("Settings"),
            //   onTap: () {},
            // ),
            ListTile(
              leading: Icon(Icons.logout, color: themeColor),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OTPLoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $userName 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            Text(
              "Disability Type: $disabilityType",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Job Listings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: jobListings.length,
                itemBuilder: (context, index) {
                  final job = jobListings[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        job["title"]!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      subtitle: Text(
                        "${job["company"]!} • ${job["location"]!}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: themeColor),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




