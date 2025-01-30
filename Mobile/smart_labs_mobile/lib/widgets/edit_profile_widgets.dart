import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import '../../models/faculty_model.dart';

class ProfileImageWidget extends StatelessWidget {
  final File? imageFile;
  final String? userImageUrl;
  final VoidCallback onImagePick;

  const ProfileImageWidget({
    super.key,
    required this.imageFile,
    required this.userImageUrl,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: imageFile != null
                  ? FileImage(imageFile!)
                  : (userImageUrl != null
                      ? NetworkImage(
                          '${dotenv.env['IMAGE_BASE_URL']}/$userImageUrl')
                      : const NetworkImage(
                          'https://picsum.photos/200')) as ImageProvider<Object>,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEB00),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: onImagePick,
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

class FacultyMajorDropdowns extends StatelessWidget {
  final String? selectedFaculty;
  final String? selectedMajor;
  final List<String> availableMajors;
  final Function(String?) onFacultyChanged;
  final Function(String?) onMajorChanged;
  final List<Faculty> faculties;
  final String? userFaculty;
  final String? userMajor;

  const FacultyMajorDropdowns({
    super.key,
    required this.selectedFaculty,
    required this.selectedMajor,
    required this.availableMajors,
    required this.onFacultyChanged,
    required this.onMajorChanged,
    required this.faculties,
    required this.userFaculty,
    required this.userMajor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedFaculty,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFFF00)),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            dropdownColor: const Color(0xFF1C1C1C),
            decoration: const InputDecoration(
              labelText: 'Faculty',
              labelStyle: TextStyle(color: Colors.white70),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: InputBorder.none,
            ),
            items: [
              if (userFaculty != null &&
                  !faculties.any((f) => f.faculty == userFaculty))
                DropdownMenuItem(
                  value: userFaculty,
                  child: Text(userFaculty!),
                ),
              ...faculties.map((faculty) {
                return DropdownMenuItem(
                  value: faculty.faculty,
                  child: Text(faculty.faculty),
                );
              }),
            ],
            onChanged: onFacultyChanged,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedMajor,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFFF00)),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            dropdownColor: const Color(0xFF1C1C1C),
            decoration: const InputDecoration(
              labelText: 'Major',
              labelStyle: TextStyle(color: Colors.white70),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: InputBorder.none,
            ),
            items: [
              if (userMajor != null &&
                  !availableMajors.contains(userMajor) &&
                  selectedFaculty == userFaculty)
                DropdownMenuItem(
                  value: userMajor,
                  child: Text(userMajor!),
                ),
              if (availableMajors.isEmpty)
                const DropdownMenuItem(
                  value: 'no_majors',
                  enabled: false,
                  child: Text('No majors available',
                      style: TextStyle(color: Colors.grey)),
                )
              else
                ...availableMajors.map((major) {
                  return DropdownMenuItem(
                    value: major,
                    child: Text(major),
                  );
                }),
            ],
            onChanged: selectedFaculty == null ? null : onMajorChanged,
          ),
        ),
      ],
    );
  }
}