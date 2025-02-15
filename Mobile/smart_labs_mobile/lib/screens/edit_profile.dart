import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_labs_mobile/controllers/edit_profile_controller.dart';
import 'package:smart_labs_mobile/models/faculty_model.dart';
import 'package:smart_labs_mobile/providers/lab_instructor_provider.dart';
import 'package:smart_labs_mobile/providers/lab_provider.dart';
import 'package:smart_labs_mobile/providers/lab_student_provider.dart';
import 'package:smart_labs_mobile/widgets/edit_profile_widgets.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../providers/faculty_provider.dart';
import 'dart:io';
class EditProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  File? _imageFile;
  String? _base64Image;
  String? _selectedFaculty;
  String? _selectedMajor;
  List<String> _availableMajors = [];

  final _controller = EditProfileController();

  @override
  void initState() {
    super.initState();
    _selectedFaculty = widget.user.faculty;
    _selectedMajor = widget.user.major;
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
    setState(() => _isLoading = true);

    try {
      final response = await _controller.saveChanges(
        formKey: _formKey,
        email: _emailController.text,
        name: _nameController.text,
        selectedMajor: _selectedMajor,
        selectedFaculty: _selectedFaculty,
        base64Image: _base64Image,
        currentUser: widget.user,
      );

      if (response['success']) {
        final userDetails = response['data'];
        final updatedUser = User(
          id: widget.user.id,
          name: _nameController.text,
          email: _emailController.text,
          imageUrl: userDetails['image'] ?? widget.user.imageUrl,
          role: widget.user.role,
          major: _selectedMajor ?? widget.user.major,
          faculty: _selectedFaculty ?? widget.user.faculty,
          faceIdentityVector: widget.user.faceIdentityVector,
          firstLogin: widget.user.firstLogin,
        );

        if (_imageFile != null) {
          imageCache.clear();
          imageCache.clearLiveImages();
        }

        // Update the user in the provider
        ref.read(userProvider.notifier).setUser(updatedUser);

        // Refresh all lab-related data
        final labProviders = ref.read(labsProvider);
        if (labProviders is AsyncData) {
          for (final lab in labProviders.value!) {
            // Refresh students and instructors for each lab
            ref.refresh(labStudentsProvider(lab.labId));
            ref.refresh(labInstructorsProvider(lab.labId));
          }
        }

        if (!mounted) return;

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  void _updateFaculty(String? value, List<Faculty> faculties) {
    setState(() {
      _selectedFaculty = value;
      _selectedMajor = null;
      _availableMajors = faculties
          .firstWhere(
            (f) => f.faculty == value,
            orElse: () => Faculty(id: 0, faculty: '', major: []),
          )
          .major;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              ProfileImageWidget(
                imageFile: _imageFile,
                userImageUrl: widget.user.imageUrl,
                onImagePick: () async {
                  try {
                    await _controller.pickImage(
                      (file) => setState(() => _imageFile = file),
                      (base64) => _base64Image = base64,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
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
              const SizedBox(height: 20),
              ref.watch(facultiesProvider).when(
                    data: (faculties) => FacultyMajorDropdowns(
                      selectedFaculty: _selectedFaculty,
                      selectedMajor: _selectedMajor,
                      availableMajors: _availableMajors,
                      onFacultyChanged: (value) =>
                          _updateFaculty(value, faculties),
                      onMajorChanged: (value) =>
                          setState(() => _selectedMajor = value),
                      faculties: faculties,
                      userFaculty: widget.user.faculty,
                      userMajor: widget.user.major,
                    ),
                    loading: () => CircularProgressIndicator(
                      color: isDark
                          ? const Color(0xFFFFFF00)
                          : theme.colorScheme.primary,
                    ),
                    error: (error, stack) => Text(
                      'Error loading faculties: $error',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFFFFEB00)
                        : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    disabledBackgroundColor: isDark
                        ? const Color(0xFFFFEB00).withValues(alpha: 0.5)
                        : theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: isDark ? Colors.black : Colors.white,
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
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
}
