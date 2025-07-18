import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  Map<String, dynamic>? profileData;

  File? _profileImage;
  Uint8List? fileBytes;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController partyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController constituencyController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final response = await supabase
        .from('users_profiles')
        .select()
        .eq('id', widget.userId)
        .maybeSingle();

    setState(() {
      profileData = response;
      isLoading = false;
    });

    if (profileData != null) {
      nameController.text = profileData!["full_name"] ?? "";
      partyController.text = profileData!["party"] ?? "";
      emailController.text = profileData!["email"] ?? "";
      phoneController.text = profileData!["phone"] ?? "";
      constituencyController.text = profileData!["constituency"] ?? "";
      bioController.text = profileData!["bio"] ?? "";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    partyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    constituencyController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _profileImage = file;
        fileBytes = bytes;
      });
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (fileBytes == null) return null;

    final filePath = 'avatars/$userId/emptyprofile.png';

    try {
      await supabase.storage.from('avatars').remove([filePath]);

      await supabase.storage.from('avatars').uploadBinary(
        filePath,
        fileBytes!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

Future<void> _submitProfile() async {
  if (!_formKey.currentState!.validate()) return;

  String? imageUrl = profileData != null ? profileData!["image_url"] : null;

  if (_profileImage != null) {
    final uploadedUrl = await _uploadProfileImage(widget.userId);
    if (uploadedUrl != null) {
      imageUrl = uploadedUrl;
    }
  }

  final updatedData = {
    "id": widget.userId,
    "full_name": nameController.text.trim(),
    "party": partyController.text.trim(),
    "email": emailController.text.trim(),
    "phone": phoneController.text.trim(),
    "constituency": constituencyController.text.trim(),
    "bio": bioController.text.trim(),
    "image_url": imageUrl,
  };

  final response = await supabase
      .from('users_profiles')
      .upsert(updatedData, onConflict: 'id');

  if (response.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving profile: ${response.error!.message}')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
    _loadUserProfile();
  }
}
@override
Widget build(BuildContext context) {
  final Color mutedPink = const Color(0xFFE6D0D8);
  final Color softGold = const Color(0xFFFFF9E6);
  final Color pinkText = const Color(0xFF9A748C);

  if (isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  if (profileData == null) {
    return _buildProfileForm();
  }

  final String name = profileData!["full_name"] ?? "";
  final String party = profileData!["party"] ?? "";
  final String imagePath = profileData!["image_url"] ?? "assets/profile.jpg";
  final String email = profileData!["email"] ?? "";
  final String phone = profileData!["phone"] ?? "";
  final String constituency = profileData!["constituency"] ?? "";
  final String termStart = profileData!["term_start"] ?? "";
  final String bio = profileData!["bio"] ?? "";
  final int electionsWon = profileData!["elections_won"] ?? 0;
  final int campaigns = profileData!["campaigns"] ?? 0;

  return Scaffold(
    backgroundColor: Colors.grey.shade100,
    appBar: AppBar(
      backgroundColor: mutedPink,
      elevation: 0,
      title: Text('$name Profile', style: TextStyle(color: pinkText)),
      centerTitle: true,
      iconTheme: IconThemeData(color: pinkText),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'profile-pic-${widget.userId}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: mutedPink.withAlpha((0.25 * 255).toInt()),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: imagePath.startsWith('http')
                      ? NetworkImage(imagePath) as ImageProvider
                      : AssetImage('assets/profile.jpg'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: pinkText),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: mutedPink, borderRadius: BorderRadius.circular(20)),
                    child: Text(party,
                        style: TextStyle(color: pinkText, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard('Elections Won', electionsWon.toString(), softGold, pinkText),
                _buildInfoCard('Campaigns', campaigns.toString(), softGold, pinkText),
              ],
            ),
            const SizedBox(height: 40),
            _buildDetailRow(Icons.email, 'Email', email, pinkText),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.phone, 'Phone', phone, pinkText),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.location_city, 'Constituency', constituency, pinkText),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, 'Term Start', termStart, pinkText),
            const SizedBox(height: 40),
            AnimatedSlide(
              offset: const Offset(0, 0.1),
              duration: const Duration(milliseconds: 400),
              child: Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),

            // 🔍 QR Code for Profile
            AnimatedOpacity(
  opacity: 1.0,
  duration: const Duration(milliseconds: 500),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🧠 About Me",
          style: TextStyle(
            color: pinkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "🌟 Vision: Empower youth through honest governance.\n\n"
          "💬 Quote: \"Be the change you wish to see.\"\n\n"
          "🗳️ Experience: $electionsWon wins, $campaigns campaigns.",
          style: TextStyle(
            color: pinkText.withOpacity(0.85),
            height: 1.5,
            fontSize: 15,
          ),
        ),
      ],
    ),
  ),
),


            const SizedBox(height: 20),
            // ❌ Follow button removed here
          ],
        ),
      ),
    ),
  );
}

 Widget _buildProfileForm() {
  final Color mutedPink = const Color(0xFFE6D0D8);
  final Color pinkText = const Color(0xFF9A748C);
  // final Color softGold = const Color(0xFFF6E7C1);

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: pinkText),
      filled: true,
      fillColor: mutedPink.withOpacity(0.3),
      labelStyle: TextStyle(color: pinkText),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: pinkText),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: pinkText, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text("Create Profile"),
      backgroundColor: mutedPink,
      iconTheme: IconThemeData(color: pinkText),
      titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Tooltip(
                message: "Tap to add profile picture",
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: mutedPink,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(Icons.add_a_photo, size: 40, color: pinkText)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: nameController,
                decoration: inputDecoration("Full Name", Icons.person),
                validator: (value) => value == null || value.isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: partyController,
                decoration: inputDecoration("Party", Icons.groups),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: inputDecoration("Email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                decoration: inputDecoration("Phone", Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: constituencyController,
                decoration: inputDecoration("Constituency", Icons.location_city),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: bioController,
                decoration: inputDecoration("Bio", Icons.info_outline),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: pinkText,
                    elevation: 5,
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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


  Widget _buildInfoCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      width: 140,
      height: 90,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: bgColor.withAlpha(100), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        Expanded(child: Text(value, style: TextStyle(color: textColor))),
      ],
    );
  }
}
