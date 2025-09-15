import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({Key? key}) : super(key: key);

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isGroup = false;
  bool _isUsingBand = false; // New state for the band toggle

  // Helper for text field validation
  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Your Trip Details"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // --- Section: Personal Info ---
            _buildSectionHeader("Personal Info"),
            _buildTextField(
              label: "Your Nickname",
              icon: Icons.person_outline,
              validator: _validateNotEmpty,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Trip Duration (in days)",
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              validator: _validateNotEmpty,
            ),
            const SizedBox(height: 24),

            // --- Section: Emergency Contacts ---
            _buildSectionHeader("Emergency Contacts"),
            _buildTextField(
              label: "Contact 1 Name",
              icon: Icons.shield_outlined,
              validator: _validateNotEmpty,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Contact 1 Phone",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _validateNotEmpty,
            ),
            const SizedBox(height: 24),

            // --- Section: Group Details ---
            _buildSectionHeader("Group Details"),
            _buildGroupToggle(),
            _buildConditionalGroupField(),
            const SizedBox(height: 24),

            // --- Section: Band Details (NEW) ---
            _buildSectionHeader("Band Details"),
            _buildBandToggle(),
            _buildConditionalBandField(),
            const SizedBox(height: 40),

            // --- Action Button ---
            CustomButton(
              text: "Continue",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Process data
                  Navigator.pushNamed(context, '/tripPlaces');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // A reusable text field widget for this form
  Widget _buildTextField({
    required String label,
    required FormFieldValidator<String> validator,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary) : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  // A header for form sections
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // The toggle for group travel
  Widget _buildGroupToggle() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        title: const Text("Are you travelling in a group?", style: TextStyle(color: AppColors.text)),
        value: _isGroup,
        onChanged: (bool? value) {
          setState(() {
            _isGroup = value ?? false;
          });
        },
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  // The animated field for group member's Aadhar
  Widget _buildConditionalGroupField() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
      child: _isGroup
          ? Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildTextField(
                label: "Phone number of any 1 member",
                icon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => _isGroup ? _validateNotEmpty(value) : null,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // The new toggle for the band
  Widget _buildBandToggle() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        title: const Text("Are you using our band?", style: TextStyle(color: AppColors.text)),
        value: _isUsingBand,
        onChanged: (bool? value) {
          setState(() {
            _isUsingBand = value ?? false;
          });
        },
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  // The new animated field for the Band ID
  Widget _buildConditionalBandField() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
      child: _isUsingBand
          ? Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildTextField(
                label: "Band ID",
                icon: Icons.sensors_outlined, // Icon for the band
                validator: (value) => _isUsingBand ? _validateNotEmpty(value) : null,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}