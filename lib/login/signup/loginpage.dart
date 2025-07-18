// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/admin/adminhomescreen.dart';
import 'package:votex/backend/auth/auth_services.dart';
import 'package:votex/login/signup/signpage.dart';
import 'package:votex/onboarding/onboarding_view.dart';
import 'package:animate_do/animate_do.dart';
import 'package:votex/user/homescreen/home_screen.dart';

final logger = Logger();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool rememberMe = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _rollnoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isAdmin = false;
  bool _obscurePassword = true;

  final authservices = AuthServices();
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeInAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _rollnoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    final username = _usernameController.text.trim();
    final rollno = _rollnoController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty || rollno.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
//new update told by mam
    if (int.tryParse(rollno) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Roll number must be a number")),
    );
    return;
  }

    if (password.length <= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be more than 6 characters')),
      );
      return;
    }

    if (username.toLowerCase() == 'admin@gmail.com' && password == 'admin123456789') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
      return;
    }

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: username,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed: No user found.")),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  VotexHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: \${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color(0xFFF4C2C2)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F3),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 30),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingView()),
                  );
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ZoomIn(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 225, 95, 139).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Welcome Back!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 235, 116, 155),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            selectedColor: Colors.white,
                            fillColor: const Color.fromARGB(255, 235, 114, 154),
                            color: Colors.black87,
                            constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
                            isSelected: [!isAdmin, isAdmin],
                            onPressed: (index) {
                              setState(() => isAdmin = index == 1);
                            },
                            children: const [
                              Text("User"),
                              Text("Admin"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _rollnoController,
                          decoration: InputDecoration(
                            hintText: 'Roll No',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            prefixIcon: const Icon(Icons.confirmation_number, color: Colors.pinkAccent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 237, 96, 143)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.pinkAccent,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value!;
                                });
                              },
                            ),
                            const Text("Remember me"),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: Add forget password logic or screen
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 14, 13, 13),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 228, 104, 145),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("Log in", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignupPage()),
                                );
                              },
                              child: const Text("Sign up", style: TextStyle(color: Colors.pinkAccent)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
