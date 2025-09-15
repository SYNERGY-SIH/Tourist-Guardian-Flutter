// lib/pages/digilocker_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';

// Enum to manage the current step of the verification flow
enum DigiLockerStep { phone, mpin, otp, aadhaar, loading }

class DigiLockerPage extends StatefulWidget {
  const DigiLockerPage({super.key});

  @override
  State<DigiLockerPage> createState() => _DigiLockerPageState();
}

class _DigiLockerPageState extends State<DigiLockerPage> {
  final _formKey = GlobalKey<FormState>();
  DigiLockerStep _currentStep = DigiLockerStep.phone;

  void _onContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    switch (_currentStep) {
      case DigiLockerStep.phone:
        _transitionToStep(DigiLockerStep.mpin, 1);
        break;
      case DigiLockerStep.mpin:
        _transitionToStep(DigiLockerStep.otp, 2);
        break;
      case DigiLockerStep.otp:
        _transitionToStep(DigiLockerStep.aadhaar, 2);
        break;
      default:
        break;
    }
  }

  void _transitionToStep(DigiLockerStep nextStep, int delayInSeconds) {
    setState(() => _currentStep = DigiLockerStep.loading);
    Future.delayed(Duration(seconds: delayInSeconds), () {
      setState(() => _currentStep = nextStep);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("DigiLocker Verification"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildCurrentStepWidget(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case DigiLockerStep.phone:
        return _buildInputForm(
          key: const ValueKey('phone'),
          label: "Phone Number",
          keyboardType: TextInputType.phone,
          maxLength: 10,
        );
      case DigiLockerStep.mpin:
        return _buildInputForm(
          key: const ValueKey('mpin'),
          label: "6-Digit MPIN",
          keyboardType: TextInputType.number,
          maxLength: 6,
          isPassword: true,
        );
      case DigiLockerStep.otp:
        return _buildInputForm(
          key: const ValueKey('otp'),
          label: "6-Digit OTP",
          keyboardType: TextInputType.number,
          maxLength: 6,
        );
      case DigiLockerStep.aadhaar:
        return _buildAadhaarDetails(key: const ValueKey('aadhaar'));
      case DigiLockerStep.loading:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        );
    }
  }

  Widget _buildInputForm({
    required Key key,
    required String label,
    required TextInputType keyboardType,
    required int maxLength,
    bool isPassword = false,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Enter your $label",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            keyboardType: keyboardType,
            maxLength: maxLength,
            obscureText: isPassword,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, letterSpacing: 8),
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.length < maxLength) {
                return "Please enter a valid $label";
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(text: "Continue", onPressed: _onContinue),
        ],
      ),
    );
  }

  // The final view showing dummy Aadhaar details
  Widget _buildAadhaarDetails({required Key key}) {
    return Card(
      key: key,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Aadhaar Details",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Divider(height: 30),

            // --- THIS IS THE MODIFIED SECTION ---
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface, // Fallback color
              // The ClipOval ensures the rectangular image is displayed as a circle
              child: ClipOval(
                child: Image.asset(
                  'assets/images/photo.png',
                  fit: BoxFit.cover,
                  width: 100, // should be double the radius
                  height: 100,
                   // Add an error builder for robustness
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 60, color: AppColors.textSecondary);
                  },
                ),
              ),
            ),
            // --- END OF MODIFIED SECTION ---

            const SizedBox(height: 16),
            _buildDetailRow("Name", "Anuj Sharma"),
            _buildDetailRow("Date of Birth", "23-06-2005"),
            _buildDetailRow("Gender", "Male"),
            _buildDetailRow("Aadhaar No.", "**** **** 1234"),
            const SizedBox(height: 24),
            CustomButton(
              text: "Next",
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/tripDetails');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title:", style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}