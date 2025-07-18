import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final logger = Logger();

class RegisterCandidateForm extends StatefulWidget {
  const RegisterCandidateForm({super.key});

  @override
  State<RegisterCandidateForm> createState() => _RegisterCandidateFormState();
}

class _RegisterCandidateFormState extends State<RegisterCandidateForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? _name, _email, _phone, _party, _designation, _gender, _age, _manifesto;
  File? _profileImage;

  final List<String> _designations = [
    'General Secretary (GS)',
    'Deputy General Secretary (Deputy GS)',
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      logger.e('Image pick failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image. Please try again.')),
      );
    }
  }

  Future<String?> _uploadImage(File file) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('User not authenticated!');
      return null;
    }

    try {
      final bytes = await file.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';

      final storageResponse = await Supabase.instance.client.storage
          .from('candidate-profile-pics')
          .uploadBinary(
            'profiles/$fileName',
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('candidate-profile-pics')
          .getPublicUrl('profiles/$fileName');

      return publicUrl;
    } catch (e) {
      logger.e('Image upload failed: $e');
      return null;
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a profile image.')),
        );
        return;
      }

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final imageUrl = await _uploadImage(_profileImage!);

      Navigator.of(context).pop();

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed. Try again.')),
        );
        return;
      }

      try {
        await supabase.from('candidates').insert({
          'user_id': userId,
          'name': _name,
          'age': int.tryParse(_age ?? '') ?? 0,
          'gender': _gender,
          'email': _email,
          'phone': _phone,
          'party': _party,
          'designation': _designation,
          'manifesto': _manifesto,
          'profile_url': imageUrl,
          'status': 'pending',
          'is_verified': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted successfully! Awaiting admin approval.')),
        );

        Navigator.pop(context);
      } catch (e) {
        logger.e('Submission failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register as Candidate"),
          backgroundColor: Colors.deepPurpleAccent.shade100,
        ),
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage:
                        _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.add_a_photo, size: 36, color: Colors.white70)
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tap the icon to upload your profile image',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),

                _animatedField(
                  child: _styledInput(TextFormField(
                    decoration: _inputDecoration('Full Name'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Enter your name' : null,
                    onSaved: (value) => _name = value,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(TextFormField(
                    decoration: _inputDecoration('Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your age' : null,
                    onSaved: (value) => _age = value,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Gender'),
                    items:
                        _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (value) => setState(() => _gender = value),
                    validator: (value) => value == null ? 'Please select gender' : null,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(TextFormField(
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Enter your email';
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                    onSaved: (value) => _email = value,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(TextFormField(
                    decoration: _inputDecoration('Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || !RegExp(r'^\d{10}$').hasMatch(value)
                            ? 'Enter 10-digit number'
                            : null,
                    onSaved: (value) => _phone = value,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(TextFormField(
                    decoration: _inputDecoration('Party Name'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Enter party name' : null,
                    onSaved: (value) => _party = value,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Designation'),
                    items: _designations
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (value) => setState(() => _designation = value),
                    validator: (value) => value == null ? 'Select designation' : null,
                  )),
                ),
                const SizedBox(height: 16),

                _animatedField(
                  child: _styledInput(TextFormField(
                    maxLines: 3,
                    decoration: _inputDecoration('Manifesto'),
                    onSaved: (value) => _manifesto = value,
                  )),
                ),
                const SizedBox(height: 24),

                _animatedField(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _submitForm(context),
                      child: const Text('Submit', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedField({required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: child,
    );
  }

  Widget _styledInput(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}
