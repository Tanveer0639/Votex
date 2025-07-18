import 'package:flutter/material.dart';

class AdminProfile extends StatelessWidget {
  final String adminName;
  final String role;
  final String imagePath;

  const AdminProfile({
    super.key,
    required this.adminName,
    required this.role,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Color scheme matching the UserProfile with muted pink & soft gold
    final Color mutedPink = const Color(0xFFE6D0D8);
    final Color softGold = const Color(0xFFFFF9E6);
    final Color pinkText = const Color(0xFF9A748C);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: mutedPink,
        elevation: 0,
        title: Text('$adminName Profile', style: TextStyle(color: pinkText)),
        centerTitle: true,
        iconTheme: IconThemeData(color: pinkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture with subtle shadow
            Container(
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
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            const SizedBox(height: 24),

            // Admin name
            Text(
              adminName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: pinkText,
              ),
            ),
            const SizedBox(height: 8),

            // Role badge with muted pink background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: mutedPink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: pinkText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info cards row - Admin specific stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard('Users Managed', '150', softGold, pinkText),
                _buildInfoCard('Elections Controlled', '8', softGold, pinkText),
              ],
            ),
            const SizedBox(height: 40),

            // Additional details section
            _buildDetailRow(Icons.email, 'Email', 'admin@example.com', pinkText),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.phone, 'Phone', '+1 987 654 3210', pinkText),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.location_city, 'Office', 'Headquarters', pinkText),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, 'Since', 'Jan 2018', pinkText),
            const SizedBox(height: 40),

            // Bio / Description
            const Text(
              'Dedicated administrator with a focus on maintaining system integrity, overseeing election processes, and ensuring seamless user management. Committed to transparency and security.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons (e.g., Contact or Settings)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Contact admin action
                    },
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mutedPink,
                      foregroundColor: pinkText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Settings or Edit profile action
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softGold,
                      foregroundColor: pinkText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for info cards with soft gold & muted pink
  Widget _buildInfoCard(String title, String value, Color goldBg, Color pinkText) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: goldBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: pinkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: pinkText.withAlpha((0.7 * 255).toInt())),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper for additional profile details row
  Widget _buildDetailRow(IconData icon, String label, String value, Color pinkText) {
    return Row(
      children: [
        Icon(icon, color: pinkText),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: pinkText,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
