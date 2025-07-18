// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:votex/user/homescreen/candidates_list_screen.dart';
// import 'package:votex/user/homescreen/userprofile.dart';
// import 'package:votex/login/signup/loginpage.dart';
// import 'package:votex/user/homescreen/register_candidate_form.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:votex/user/notifications/notifications_screen.dart';
// import 'package:votex/user/homescreen/myvotescreen.dart';
// import 'package:votex/user/homescreen/userresultsscreen.dart';


// class VotexHomeScreen extends StatefulWidget {
//   const VotexHomeScreen({super.key});

//   @override
//   State<VotexHomeScreen> createState() => _VotexHomeScreenState();
// }

// class _VotexHomeScreenState extends State<VotexHomeScreen> with SingleTickerProviderStateMixin {
//   bool showMenu = false;
//   final PageController _candidateController = PageController(viewportFraction: 0.8);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5F9),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 60, left: 16, right: 16,),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSearchBar(),
//                 const SizedBox(height: 24),
//                 _buildRegisterAsCandidateSection(),

//                 _buildCategories(),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Popular Candidates',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildCandidateCarousel(),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Latest News',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildNewsFeed(),
//               ],
//             ),
//           ),
//           _buildAppBar(),
//           if (showMenu)
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showMenu = false;
//                   });
//                 },
//                 child: Container(
//                   color: Colors.black.withAlpha((0.4 * 255).toInt()),
//                 ),
//               ),
//             ),
//           _buildSideMenu(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(LucideIcons.menu, color: Colors.black),
//               onPressed: () {
//                 setState(() {
//                   showMenu = !showMenu;
//                 });
//               },
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Votex',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.notifications_none),
//               onPressed: () {
//                 Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const NotificationsScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//  Widget _buildSideMenu() {
//   return AnimatedPositioned(
//     duration: const Duration(milliseconds: 300),
//     top: 0,
//     bottom: 0,
//     left: showMenu ? 0 : -250,
//     child: Material(
//       elevation: 10,
//       child: Container(
//         width: 250,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFFFD1DC), Color(0xFFFFF0B3)], // pink to gold gradient
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Section
//             Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 24,
//                   backgroundImage: AssetImage('assets/profile.jpg'), // Replace with actual image path
//                 ),
//                 const SizedBox(width: 12),
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("USER", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
//                     Text("Student", style: TextStyle(color: Colors.black87, fontSize: 12)),
//                   ],
//                 )
//               ],
//             ),
//             const SizedBox(height: 40),

//             // Menu Items
//             _buildMenuItem(LucideIcons.layoutDashboard, "Dashboard", () {}),
//             _buildMenuItem(LucideIcons.user, "My Profile", () {}),
//             _buildMenuItem(LucideIcons.settings, "Settings", () {}),
//             const Spacer(),
//             const Divider(color: Colors.black26),
//             _buildMenuItem(LucideIcons.logOut, "Logout", () {
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const LoginPage()),
//                    (Route<dynamic> route) => false,
//                 );
//             }),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
//   return InkWell(
//     onTap: onTap,
//     borderRadius: BorderRadius.circular(12),
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.black87, size: 22),
//           const SizedBox(width: 12),
//           Text(label, style: const TextStyle(color: Colors.black87, fontSize: 16)),
//         ],
//       ),
//     ),
//   );
// }




//   Widget _buildSearchBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: const TextField(
//         decoration: InputDecoration(
//           hintText: 'Search candidate or party...',
//           icon: Icon(Icons.search),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }

// Widget _buildCategories() {
//   final currentUser = Supabase.instance.client.auth.currentUser;

//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       _buildCategory(LucideIcons.user, 'Profile', () {
//         if (currentUser != null) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UserProfile(userId: currentUser.id),
//             ),
//           );
//         } else {
//           // Optional: handle unauthenticated user case
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User not logged in')),
//           );
//         }
//       }),
//       _buildCategory(LucideIcons.userCheck, 'Candidates', () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const CandidatesListScreen()),
//         );
//       }),
// _buildCategory(LucideIcons.vote, 'My Vote', () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => MyVoteScreen()),
//   );
// }),

//       _buildCategory(LucideIcons.barChart2, 'Results', () {
//           Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => UserResultsScreen()),
//   );
//       }),
//     ],
//   );
// }




//   Widget _buildCategory(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(
//             backgroundColor: const Color(0xFF334155),
//             radius: 26,
//             child: Icon(icon, color: Colors.white),
//           ),
//           const SizedBox(height: 6),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCandidateCarousel() {
//     final candidates = [
//       {
//         'name': 'Laiba Khan',
//         'party': 'Reform Party',
//         'image': 'assets/girl.jpg',
//       },
//       {
//         'name': 'Ravi Singh',
//         'party': 'Unity Party',
//         'image': 'assets/boy.jpg',
//       },
//       {
//         'name': 'Leela Patel',
//         'party': 'Progressive',
//         'image': 'assets/girl2.jpg',
//       },
//     ];

//     return SizedBox(
//       height: 160,
//       child: PageView.builder(
//         controller: _candidateController,
//         itemCount: candidates.length,
//         itemBuilder: (context, index) {
//           final candidate = candidates[index];
//           final imagePath = candidate['image'] as String;

//           final imageWidget = Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.cover);

//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             margin: const EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
//             ),
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: imageWidget,
//                 ),
//                 const SizedBox(width: 16),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(candidate['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(height: 4),
//                     Text(candidate['party']!, style: const TextStyle(color: Colors.grey)),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
//                       child: const Text("View"),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

// Widget _buildRegisterAsCandidateSection() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Want to Lead?',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ElevatedButton.icon(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const RegisterCandidateForm(),
//               ),
//             );
//           },
//           icon: const Icon(Icons.how_to_reg),
//           label: const Text('Register as Candidate'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF9333EA), // Light purple
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 4,
//           ),
//         ),
//       ],
//     ),
//   );
// }


//   }


//   Widget _buildNewsFeed() {
//     final news = [
//       "Elections to be held on June 15",
//       "Reform Party releases manifesto",
//       "Voting awareness drive begins in district",
//     ];

//     return Column(
//       children: news.map((item) {
//         return AnimatedOpacity(
//           duration: const Duration(milliseconds: 500),
//           opacity: 1,
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.newspaper, color: Colors.black54),
//                 const SizedBox(width: 12),
//                 Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// new
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:votex/user/homescreen/candidates_list_screen.dart';
import 'package:votex/user/homescreen/userprofile.dart';
import 'package:votex/login/signup/loginpage.dart';
import 'package:votex/user/homescreen/register_candidate_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/user/notifications/notifications_screen.dart';
import 'package:votex/user/homescreen/myvotescreen.dart';
import 'package:votex/user/homescreen/userresultsscreen.dart';

class VotexHomeScreen extends StatefulWidget {
  const VotexHomeScreen({super.key});

  @override
  State<VotexHomeScreen> createState() => _VotexHomeScreenState();
}

class _VotexHomeScreenState extends State<VotexHomeScreen>
    with SingleTickerProviderStateMixin {
  bool showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F4),
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildRegisterAsCandidateSection(),
                  const SizedBox(height: 24),
                  _buildCategories(),
                  const SizedBox(height: 30),
                  _buildInspiringBanner(),
                  const SizedBox(height: 30),
                  _buildExtraFeatures(), // 👈 Moved above
                  const SizedBox(height: 30),
                  _buildInformationCards(),
                ],
              ),
            ),
          ),
          _buildAppBar(),
          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showMenu = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
          _buildSideMenu(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.menu, color: Colors.black),
              onPressed: () {
                setState(() {
                  showMenu = !showMenu;
                });
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Votex',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search candidate or party...',
          icon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRegisterAsCandidateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4EC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Initiate Change',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Want to lead? Step forward with courage.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterCandidateForm()),
              );
            },
            icon: const Icon(Icons.how_to_reg),
            label: const Text('Register as Candidate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildCategoryBox(LucideIcons.user, 'My Profile', () {
          if (currentUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfile(userId: currentUser.id),
              ),
            );
          }
        }),
        _buildCategoryBox(LucideIcons.userCheck, 'Candidates', () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CandidatesListScreen()),
          );
        }),
        _buildCategoryBox(LucideIcons.vote, 'My Votes', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyVoteScreen()),
          );
        }),
        _buildCategoryBox(LucideIcons.barChart2, 'Results', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserResultsScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryBox(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.pinkAccent),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspiringBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC1D9), Color(0xFFFFE0EC)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\"Your Vote, Your Voice!\"",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 8),
          Text("– Votex Initiative",
              style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
    Widget _buildExtraFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore More',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(Icons.lightbulb_outline, 'Voting Tips',
            'Discover helpful voting strategies to make informed choices.'),
        _buildFeatureCard(Icons.event, 'Upcoming Events',
            'Stay updated with debates, discussions, and election news.'),
        _buildFeatureCard(Icons.security, 'Secure Voting',
            'Learn how your votes are protected using modern tech.'),
        _buildFeatureCard(Icons.people_alt, 'Community Voices',
            'Hear what other students are saying and participate.'),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4EC), Color(0xFFFFF0F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }


  Widget _buildInformationCards() {
    final infos = [
      "Get Ready for the Big Day – Elections on June 15!",
      "Reform Party announces dynamic manifesto goals!",
      "Join the Vote Awareness Week now!",
      "Student Parliament – new changes incoming!",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What's New",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...infos.map((text) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.pinkAccent),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(text,
                          style: const TextStyle(fontSize: 14))),
                ],
              ),
            ))
      ],
    );
  }

  Widget _buildSideMenu() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: 0,
      bottom: 0,
      left: showMenu ? 0 : -250,
      child: Material(
        elevation: 10,
        child: Container(
          width: 250,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD1DC), Color(0xFFFFF0B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("USER",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text("Student",
                          style:
                              TextStyle(color: Colors.black87, fontSize: 12)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 40),
              _buildMenuItem(LucideIcons.layoutDashboard, "Dashboard", () {
                setState(() {
                  showMenu = false;
                });
              }),
              _buildMenuItem(LucideIcons.user, "My Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UserProfile(userId: Supabase.instance.client.auth.currentUser!.id)),
                );
              }),
              _buildMenuItem(LucideIcons.settings, "Settings", () {}),
              const Spacer(),
              const Divider(color: Colors.black26),
              _buildMenuItem(LucideIcons.logOut, "Logout", () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style:
                    const TextStyle(color: Colors.black87, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
