import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:votex/login/signup/loginpage.dart';
import 'package:votex/admin/admin_panel/manage_users.dart';
import 'package:votex/admin/adminprofile.dart';
import 'package:votex/admin/admin_panel/verify_candidates.dart';
import 'package:votex/admin/admin_panel/control_elections.dart';
import 'package:votex/admin/admin_panel/view_results.dart';
// AdminHomeScreen with slide menu and logout button at bottom of screen
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {
  bool showMenu = false;
  late AnimationController _controller;
  late Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _menuAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
      if (showMenu) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildHeaderWithProfileCard(),
                  const SizedBox(height: 32),
                  Expanded(child: _buildAdminActions()),

                  // Logout button fixed at bottom of the screen inside the column
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sidebar menu with animation
          AnimatedBuilder(
            animation: _menuAnimation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                bottom: 0,
                left: -250 + (250 * _menuAnimation.value), // slide from left
                child: _buildSideMenu(),
              );
            },
          ),

          // Dark overlay when menu is open
          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: toggleMenu,
                child: Container(color: Colors.black.withAlpha((255 * 0.4).toInt())),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconButton(
          icon: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller, color: Colors.black87),
          onPressed: toggleMenu,
          tooltip: "Toggle Menu",
        ),
        const SizedBox(width: 8),
        const Text(
          'Admin Panel',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black54),
          onPressed: () {
            // TODO: Add notification logic here
          },
          tooltip: "Notifications",
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search users or candidates...',
          icon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildHeaderWithProfileCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Admin Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              SizedBox(height: 6),
              Text(
                'Manage users, candidates, and elections',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            // TODO: Navigate to admin profile page
            Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => const AdminProfile(
                     adminName: 'Tanveer',
                     role: 'Super Admin',
                     imagePath: 'assets/admin_profile.png',),
                  )
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: const [
                CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/admin.png')),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Administrator', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      padding: EdgeInsets.zero,
      children: [
        _buildAdminTile(
          LucideIcons.users,
          "Manage Users",
          Colors.blue.shade700,
          () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => const ManageUsersScreen(),
      ),
    );
  },
),

      _buildAdminTile(
        LucideIcons.userCheck,
        "Verify Candidates",
        Colors.green.shade700,
        () {
                 Navigator.push(
                 context,
                 MaterialPageRoute(
                 builder: (context) => const VerifyCandidates(),
          ),
      );
              
  },
),
        _buildAdminTile(
          LucideIcons.slidersHorizontal,
          "Control Elections",
          Colors.orange.shade700,
          () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => const ControlElection(),
      ),
    );
          },
        ),
        _buildAdminTile(
          LucideIcons.barChart2,
          "View Results",
          Colors.purple.shade700,
          () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) =>  AdminResultsScreen(),
      ),
    );           
          },
        ),
      ],
    );
  }

  Widget _buildAdminTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color, radius: 28, child: Icon(icon, size: 32, color: Colors.white)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenu() {
    return Material(
      elevation: 20,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD1DC), Color(0xFFFFF0B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
          boxShadow: [
           BoxShadow(
            color: Colors.black.withAlpha(38), // 0.15 opacity
            blurRadius: 15,
            offset: Offset(4, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/admin.png')),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Administrator", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            _buildMenuItem(LucideIcons.layoutDashboard, "Dashboard", () {
              toggleMenu();
            }),
            _buildMenuItem(LucideIcons.settings, "Settings", () {
              toggleMenu();
              // TODO: Navigate to Settings page
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
