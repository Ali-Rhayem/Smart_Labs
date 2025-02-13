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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                          : const NetworkImage('https://picsum.photos/200'))
                      as ImageProvider<Object>,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFFFEB00)
                      : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: isDark ? Colors.black : Colors.white,
                  ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle:
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFFEB00) : theme.colorScheme.primary,
          ),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dropdownDecoration = BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDark
            ? Colors.white24
            : theme.colorScheme.onSurface.withOpacity(0.2),
      ),
    );

    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: InputBorder.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: dropdownDecoration,
          child: DropdownButtonFormField<String>(
            value: selectedFaculty,
            icon: Icon(
              Icons.arrow_drop_down,
              color:
                  isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
            ),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
            ),
            dropdownColor:
                isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
            decoration: inputDecoration.copyWith(labelText: 'Faculty'),
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
          decoration: dropdownDecoration,
          child: DropdownButtonFormField<String>(
            value: selectedMajor,
            icon: Icon(
              Icons.arrow_drop_down,
              color:
                  isDark ? const Color(0xFFFFFF00) : theme.colorScheme.primary,
            ),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
            ),
            dropdownColor:
                isDark ? const Color(0xFF1C1C1C) : theme.colorScheme.surface,
            decoration: inputDecoration.copyWith(labelText: 'Major'),
            items: [
              if (userMajor != null &&
                  !availableMajors.contains(userMajor) &&
                  selectedFaculty == userFaculty)
                DropdownMenuItem(
                  value: userMajor,
                  child: Text(userMajor!),
                ),
              if (availableMajors.isEmpty)
                DropdownMenuItem(
                  value: 'no_majors',
                  enabled: false,
                  child: Text(
                    'No majors available',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
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
