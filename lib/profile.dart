import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfPage extends StatefulWidget {
  const ProfPage({super.key});

  @override
  _ProfPageState createState() => _ProfPageState();
}

class _ProfPageState extends State<ProfPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isEditing = false;
  File? _image; // Store selected image

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load saved user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? "";
      _emailController.text = prefs.getString('email') ?? "";
      _phoneController.text = prefs.getString('phone') ?? "";
      _addressController.text = prefs.getString('address') ?? "";
      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        _image = File(imagePath);
      }
    });
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('address', _addressController.text);
    if (_image != null) {
      await prefs.setString('profile_image', _image!.path);
    }

    setState(() {
      _isEditing = false; // Exit edit mode
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated!")),
    );
  }

  // Pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!) as ImageProvider
                      : const AssetImage('assets/profile.png'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildEditableField("Name", _nameController),
            const SizedBox(height: 10),
            _buildEditableField("Email", _emailController),
            const SizedBox(height: 10),
            _buildEditableField("Phone", _phoneController),
            const SizedBox(height: 10),
            _buildEditableField("Address (Optional)", _addressController),
            const SizedBox(height: 20),

            _isEditing
                ? ElevatedButton(
                    onPressed: _saveUserData,
                    child: const Text("Save"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: const Text("Edit"),
                  ),

            const SizedBox(height: 20),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to Settings page
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget for input fields (editable/non-editable)
  Widget _buildEditableField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      enabled: _isEditing, // Editable only when in edit mode
    );
  }
}
