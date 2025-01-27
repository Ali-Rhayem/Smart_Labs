import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/utils/secure_storage.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final id = await _secureStorage.readId();
    final role = await _secureStorage.readRole();
    setState(() => _isLoading = true);

    final Map<String, dynamic> updateData = {
      'id': int.parse(id!),
      'email': _emailController.text,
      'name': _nameController.text,
      'role': role,
      'password': '12343',
      'major':'Computer Science',
      'faculty':'Engineering',
    };

    // Add image if it was updated
    if (_base64Image != null) {
      updateData['image'] = 'data:image/jpeg;base64,$_base64Image';
    } else if (widget.user.imageUrl != null) {
      updateData['image'] = widget.user.imageUrl;
    }

    final response = await _apiService.put('/User/$id', updateData);

    if (!mounted) return;

    if (response['success']) {
      // Update the user in the provider
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        email: _emailController.text,
        imageUrl: response['data']['image'] ?? widget.user.imageUrl,
        role: widget.user.role,
        major: widget.user.major,
        faculty: widget.user.faculty,
        faceIdentityVector: widget.user.faceIdentityVector,
      );

      ref.read(userProvider.notifier).setUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? 'Failed to update profile')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Convert image to base64
      final bytes = await _imageFile!.readAsBytes();
      _base64Image = base64Encode(bytes);
      print('base64Image: $_base64Image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileImage(),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEB00),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : (widget.user.imageUrl != null
                          ? NetworkImage('${dotenv.env['IMAGE_BASE_URL']}/${widget.user.imageUrl}')
                          : const NetworkImage('https://picsum.photos/200'))
                      as ImageProvider<Object>,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEB00),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
