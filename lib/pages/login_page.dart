// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/pages/digilocker_page.dart'; // <-- 1. IMPORT the new page

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List<String> _languages = [
    'English', 'Hindi', 'Bengali', 'Marathi', 'Telugu', 'Tamil',
    'Gujarati', 'Urdu', 'Kannada', 'Odia', 'Malayalam', 'Punjabi',
  ];
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background layers...
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset('assets/images/seven_sisters_welcome.png', fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.background),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          
          // UI Content layer...
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language Dropdown...
                  Align(
                    alignment: Alignment.topRight,
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      dropdownColor: Colors.black.withOpacity(0.8),
                      underline: Container(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onChanged: (String? newValue) => setState(() => _selectedLanguage = newValue!),
                      items: _languages.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                    ),
                  ),
                  
                  const Spacer(flex: 1),

                  SvgPicture.asset(
                    'assets/images/ashoka_chakra.svg',
                      height: 100,
                      width: 100,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),

                  const SizedBox(height: 24),
                  
                  // Welcome Text...
                  const Text("Welcome\nস্বাগতম\nस्वागत",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text("Your personal travel companion",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 3),

                  // Action Buttons...
                  CustomButton(text: "Foreign / NRI Login", onPressed: () {}),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: "Self-Register",
                    onPressed: () {
                      // --- 2. THIS IS THE ONLY CHANGE YOU NEED TO MAKE ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DigiLockerPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: "Counter Desk Register",
                    onPressed: () {
                      Navigator.pushNamed(context, '/tripDetails');
                    },
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}