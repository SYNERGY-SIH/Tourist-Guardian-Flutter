import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/l10n/app_localizations.dart';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isGroup = false;
  bool _isUsingBand = false;

  String? _validateNotEmpty(String? value, String errorText) {
    if (value == null || value.trim().isEmpty) {
      return errorText;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.yourTripDetails),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSectionHeader(l10n.personalInfo),
            _buildTextField(
              label: l10n.yourNickname,
              icon: Icons.person_outline,
              validator: (val) => _validateNotEmpty(val, l10n.validationCannotBeEmpty),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: l10n.tripDurationInDays,
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              validator: (val) => _validateNotEmpty(val, l10n.validationCannotBeEmpty),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(l10n.emergencyContacts),
            _buildTextField(
              label: l10n.contact1Name,
              icon: Icons.shield_outlined,
              validator: (val) => _validateNotEmpty(val, l10n.validationCannotBeEmpty),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: l10n.contact1Phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (val) => _validateNotEmpty(val, l10n.validationCannotBeEmpty),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(l10n.groupDetails),
            _buildGroupToggle(l10n.areYouTravellingInAGroup),
            _buildConditionalGroupField(l10n),
            const SizedBox(height: 24),

            _buildSectionHeader(l10n.bandDetails),
            _buildBandToggle(l10n.areYouUsingOurBand),
            _buildConditionalBandField(l10n),
            const SizedBox(height: 40),

            CustomButton(
              text: l10n.continueButton,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, '/tripPlaces');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildGroupToggle(String title) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(color: AppColors.text)),
        value: _isGroup,
        onChanged: (bool? value) => setState(() => _isGroup = value ?? false),
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildConditionalGroupField(AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
      child: _isGroup
          ? Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildTextField(
                label: l10n.phoneNumber1Member,
                icon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => _isGroup ? _validateNotEmpty(value, l10n.validationCannotBeEmpty) : null,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBandToggle(String title) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(color: AppColors.text)),
        value: _isUsingBand,
        onChanged: (bool? value) => setState(() => _isUsingBand = value ?? false),
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildConditionalBandField(AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
      child: _isUsingBand
          ? Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildTextField(
                label: l10n.bandId,
                icon: Icons.sensors_outlined,
                validator: (value) => _isUsingBand ? _validateNotEmpty(value, l10n.validationCannotBeEmpty) : null,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}