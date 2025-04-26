import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheat_rust_detection_application/api_services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String firstName = '';
  String lastName = '';
  String _role = '';
  String email = '';
  String phoneNumber = '';
  String birth = '';
  String gender = '';
  final ApiService _apiService = ApiService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('name')?.split(' ').first ?? '';
      lastName = prefs.getString('name')?.split(' ').last ?? '';
      _role = prefs.getString('role') ?? '';
      email = prefs.getString('email') ?? '';

      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _emailController.text = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5E4E2), // Light Grey background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    // TODO: Navigation code
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGVyc29ufGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60"),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Edit Profile Title
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),

              // Form Fields
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
              ),
              SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField(
                value: _role.isNotEmpty ? _role : null,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
                items: ["farmer"]
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _role = value.toString()),
                dropdownColor: Colors.white, //White background
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+251 ',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
              ),
              SizedBox(height: 16),

              //Birth Dropdown
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Birth',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
                items: ['1999', '2000']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  // TODO: Add what happens on change
                },
                dropdownColor: Colors.white, //White background
              ),
              SizedBox(height: 16),

              //Gender Dropdown
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                    borderSide: BorderSide.none, // Remove border line
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.white, // White background
                ),
                items: ['Male', 'Female']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  // TODO: Add what happens on change
                },
                dropdownColor: Colors.white, //White background
              ),
              SizedBox(height: 24),

              // Change Password Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement change password functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF008080), // Teal color
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(25.0), // Rounded corners
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Change Password'),
                    SizedBox(width: 8),
                    Icon(Icons.lock, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
