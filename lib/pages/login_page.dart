import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2), // Pushes content down from the top

              // App Icon/Logo
              const Icon(
                Icons.tour_rounded,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // Welcome Text
              const Text(
                "Welcome\nস্বাগতম\nस्वागत",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Your personal travel companion",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3), // Pushes buttons to the bottom

              // Action Buttons
              CustomButton(
                text: "Self-Register",
                onPressed: () {
                  Navigator.pushNamed(context, '/tripDetails');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Counter Desk Register",
                onPressed: () {
                  // For now, this button can also lead to the same flow
                  Navigator.pushNamed(context, '/tripDetails');
                },
              ),
              const Spacer(flex: 1), // Some padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}