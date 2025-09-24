import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/pages/digilocker_page.dart';
import 'package:my_app/pages/trip_details_page.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/locale_provider.dart';
import 'package:my_app/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- MODIFIED: Added the 7 new languages to this list ---
  final Map<String, String> _supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी', // Hindi
    'mr': 'मराठी', // Marathi
    'as': 'অসমীয়া', // Assamese
    'mni': 'মৈতৈলোন্', // Manipuri (Meiteilon)
    'lus': 'Mizo', // Mizo
    'kha': 'Khasi', // Khasi
    'trp': 'Kokborok', // Kokborok
    'njz': 'Nyishi', // Nyishi
    'nbe': 'Konyak', // Konyak
  };

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProvider.locale.languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/seven_sisters_welcome.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: DropdownButton<String>(
                      value: currentLangCode,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      dropdownColor: Colors.black.withOpacity(0.8),
                      underline: Container(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onChanged: (String? newCode) {
                        if (newCode != null) {
                          localeProvider.setLocale(Locale(newCode));
                        }
                      },
                      items: _supportedLanguages.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                  const Spacer(flex: 1),
                  SvgPicture.asset(
                    'assets/images/ashoka_chakra.svg',
                    height: 100,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.welcomeMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tagline,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  CustomButton(
                    text: l10n.foreignNriLogin,
                    onPressed: () {
                      // This button does nothing on click as per requirement
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: l10n.selfRegister,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DigiLockerPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: l10n.counterDeskRegister,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TripDetailsPage()),
                      );
                    },
                  ),
                  /* --- SIGN IN BUTTON AND DIVIDER COMMENTED OUT FOR FUTURE USE ---
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white70),
                  ),
                  CustomButton(
                    text: l10n.signIn,
                    onPressed: () {
                      // TODO: Add sign in logic here
                    },
                  ),
                  */
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