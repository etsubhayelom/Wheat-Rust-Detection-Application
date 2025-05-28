import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/constants.dart';
import 'package:wheat_rust_detection_application/views/review_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _error;

  String? lastName;
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String _role = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final ApiService apiService = ApiService();

  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userProfile = await ApiService().fetchUserProfile();
      setState(() {
        _name = userProfile['name'] ?? '';
        _email = userProfile['email'] ?? '';
        _phoneNumber = userProfile['phone'] ?? '';
        _role = userProfile['role'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {});

    try {
      final response = await ApiService().updateProfile(
        name: _name,
        email: _email,
        phoneNumber: _phoneNumber,
        role: _role,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(true); // Return to profile page
      } else {
        debugPrint('Failed to update profile: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    if (_role != "expert" && _role != "researcher") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You must be an expert or researcher to upload a certificate.')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File pdfFile = File(result.files.single.path!);

      debugPrint('Selected PDF file: $pdfFile');
      try {
        final response =
            await apiService.uploadProofOfQualification(pdfFile, _role);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReviewPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload proof: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      // User canceled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double avatarRadius = 60;
    double backgroundHeight = 200;
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE5E4E2),
      body: SingleChildScrollView(
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height + 100, // ensure enough space
          child: Stack(
            children: [
              // Background and decorations
              SizedBox(
                width: double.infinity,
                height: backgroundHeight + avatarRadius,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/background.png',
                      width: double.infinity,
                      height: backgroundHeight,
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/Ellipse-7.png',
                        height: 300,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 30,
                      child: Container(
                        width: 50,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.rectangle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // White container
              Positioned(
                top: backgroundHeight - avatarRadius / 2,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.editProfile,
                          style: const TextStyle(
                            fontSize: 24,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: _name,
                              onSaved: (value) => _name = value ?? '',
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.firstName,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.lastName,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField(
                              value: (_role.isNotEmpty) ? _role : null,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.role,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: ["farmer", "researcher", "expert"]
                                  .map((label) => DropdownMenuItem(
                                        value: label,
                                        child: Text(label[0].toUpperCase() +
                                            label.substring(1)),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _role = value.toString()),
                              dropdownColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _email,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.email,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _phoneNumber,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.phoneNumber,
                                prefixText: '+251 ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hexToColor('124A7D'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.changePassword,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.lock,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hexToColor('124A7D'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.updateProfile,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _pickPdfFile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hexToColor('14AE5C'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .uploadProofOfExpertCertification,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // CircleAvatar overlapping both background and container
              Positioned(
                top: 100,
                left: MediaQuery.of(context).size.width / 2 - avatarRadius,
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage("assets/images/splash1.png")
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hexToColor('124A7D'),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.edit,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
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
