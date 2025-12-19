import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen ({super.key});

  // Using colors as defined in the project
  static const Color brandColor = Color(0xFFF97316); // Orange
  static const Color bgColor = Color(0xFFFFEDD5); // Cream

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 150,
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.barriecito(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                  ),
                ),
                const Text(
                  "Log in to continue",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),

                const SizedBox(height: 16),
                _buildTextField(
                  hintText: "Email address",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                  ],
                ),

                const SizedBox(height: 30),

                // Google Sign Up
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: brandColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_Logo.svg/1024px-Google_\"G\"_Logo.svg.png',
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            color: brandColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: brandColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        suffixIcon: isPassword
            ? Icon(
          Icons.visibility_off,
          color: Colors.grey.shade400,
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: brandColor, width: 1),
        ),
      ),
    );
  }
}
