// lib/pages/digilocker_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/l10n/app_localizations.dart';

enum DigiLockerStep { phone, mpin, otp, aadhaar, loading }

class DigiLockerPage extends StatefulWidget {
  const DigiLockerPage({super.key});

  @override
  State<DigiLockerPage> createState() => _DigiLockerPageState();
}

class _DigiLockerPageState extends State<DigiLockerPage> {
  final _formKey = GlobalKey<FormState>();
  DigiLockerStep _currentStep = DigiLockerStep.phone;

  // --- NEW: State variables for dynamic data ---
  late final TextEditingController _phoneController;
  late final TextEditingController _mpinController;
  late final TextEditingController _otpController;

  List<Map<String, dynamic>> _usersData = [];
  Map<String, dynamic>? _currentUser;
  final String _commonOtp = "123456"; // The common OTP for validation

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _mpinController = TextEditingController();
    _otpController = TextEditingController();
    _loadUsersData(); // Load the JSON data when the page starts
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _phoneController.dispose();
    _mpinController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- NEW: Method to load and parse the users.json file ---
  Future<void> _loadUsersData() async {
    final String jsonString = await rootBundle.loadString('assets/data/users.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      _usersData = jsonList.cast<Map<String, dynamic>>();
    });
  }

  // --- MODIFIED: The core logic for validation ---
  void _onContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    String errorMessage = "An error occurred.";

    switch (_currentStep) {
      case DigiLockerStep.phone:
        final phone = _phoneController.text;
        final user = _usersData.where((user) => user['phone'] == phone).firstOrNull;

        if (user != null) {
          _currentUser = user;
          _transitionToStep(DigiLockerStep.mpin);
        } else {
          errorMessage = "Phone number not found.";
        }
        break;

      case DigiLockerStep.mpin:
        final mpin = _mpinController.text;
        if (_currentUser != null && _currentUser!['mpin'] == mpin) {
          _transitionToStep(DigiLockerStep.otp);
        } else {
          errorMessage = "Incorrect MPIN.";
        }
        break;

      case DigiLockerStep.otp:
        final otp = _otpController.text;
        if (otp == _commonOtp) {
          _transitionToStep(DigiLockerStep.aadhaar);
        } else {
          errorMessage = "Incorrect OTP.";
        }
        break;
      default:
        return; // Do nothing for other steps
    }

    // Show error message if validation failed for any step
    if (_currentUser == null ||
        (_currentStep == DigiLockerStep.mpin && _currentUser!['mpin'] != _mpinController.text) ||
        (_currentStep == DigiLockerStep.otp && _otpController.text != _commonOtp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    }
  }

  // --- MODIFIED: Simplified transition logic ---
  void _transitionToStep(DigiLockerStep nextStep) {
    setState(() => _currentStep = DigiLockerStep.loading);
    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if(mounted) {
        setState(() => _currentStep = nextStep);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.digilockerVerification),
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

  // --- MODIFIED: Passes the correct controller to the input form ---
  Widget _buildCurrentStepWidget() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case DigiLockerStep.phone:
        return _buildInputForm(
          key: const ValueKey('phone'),
          controller: _phoneController,
          label: l10n.phoneNumber,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        );
      case DigiLockerStep.mpin:
        return _buildInputForm(
          key: const ValueKey('mpin'),
          controller: _mpinController,
          label: l10n.sixDigitMpin,
          keyboardType: TextInputType.number,
          maxLength: 6,
          isPassword: true,
        );
      case DigiLockerStep.otp:
        return _buildInputForm(
          key: const ValueKey('otp'),
          controller: _otpController,
          label: l10n.sixDigitOtp,
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

  // --- MODIFIED: Now accepts a TextEditingController ---
  Widget _buildInputForm({
    required Key key,
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required int maxLength,
    bool isPassword = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.enterYourLabel(label),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: controller, // Use the passed controller
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
                return l10n.pleaseEnterAValidLabel(label);
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(text: l10n.continueButton, onPressed: _onContinue),
        ],
      ),
    );
  }

  // --- MODIFIED: Displays data from the _currentUser object ---
  Widget _buildAadhaarDetails({required Key key}) {
    final l10n = AppLocalizations.of(context)!;
    
    // Fallback if current user is somehow null
    if (_currentUser == null) {
      return const Center(child: Text("Error: User data not found."));
    }

    return Card(
      key: key,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.aadhaarDetails,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Divider(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface,
              child: ClipOval(
                child: Image.asset(
                  _currentUser!['photoUrl'],
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 60, color: AppColors.textSecondary);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(l10n.name, _currentUser!['name']),
            _buildDetailRow(l10n.dateOfBirth, _currentUser!['dob']),
            _buildDetailRow(l10n.gender, _currentUser!['gender']),
            _buildDetailRow(l10n.aadhaarNo, _currentUser!['aadhaar']),
            const SizedBox(height: 24),
            CustomButton(
              text: l10n.next,
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