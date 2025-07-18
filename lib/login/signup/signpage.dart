import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/backend/auth/auth_services.dart';
import 'package:votex/login/signup/loginpage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _agreeToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void handleSignup() async {
    final firstname = _firstNameController.text.trim();
    final lastname = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final rollno = _rollController.text.trim();
    final password = _passwordController.text;
    final confirmpassword = _confirmPasswordController.text;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must agree to the privacy policy.")));
      return;
    }

    if ([firstname, lastname, email, rollno, password, confirmpassword].any((element) => element.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be more than 6 characters")));
      return;
    }

    if (password != confirmpassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    try {
      final response = await authservices.signUpWithEmailPassword(email, password);
      final user = response.user;

      if (user != null) {
        await Supabase.instance.client.from('users_list').insert({
          'id': user.id,
          'email': email,
          'name': firstname,
          'rollno': rollno,
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        throw Exception("Signup successful but user object is null.");
      }
    } catch (e) {
      print("Signup error: $e");
      String errorMessage = "Signup failed. Please try again.";

      if (e is AuthException) {
        if (e.message.contains("already registered")) {
          errorMessage = "This email is already registered. Please log in instead.";
        } else {
          errorMessage = e.message;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color(0xFFF4C2C2)),
    );

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD1DC), Color(0xFFF4C2C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 240, 245, 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.pinkAccent.withAlpha(51), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Create Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              hint: "First Name",
                              border: border,
                              icon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              hint: "Last Name",
                              border: border,
                              icon: Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        hint: "Email",
                        border: border,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _rollController,
                        hint: "Roll No",
                        border: border,
                        icon: Icons.account_box_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "Password",
                        border: border,
                        icon: Icons.lock_outline,
                        obscureText: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.pink),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: "Confirm Password",
                        border: border,
                        icon: Icons.lock,
                        obscureText: !_showConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.pink),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            activeColor: const Color(0xFFFFD700),
                            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              "I agree to the Privacy Policy",
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4C2C2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.black87)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Sign In", style: TextStyle(color: Color(0xFFE75480))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required OutlineInputBorder border,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFE75480)) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withAlpha(230),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }
}
