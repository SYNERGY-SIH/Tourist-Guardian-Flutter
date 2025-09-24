// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/pages/basic_info_page.dart';
import 'package:my_app/pages/stats_page.dart';
import 'package:my_app/pages/offline_map_page.dart';
import 'package:my_app/pages/chat_bot_page.dart';
import 'package:my_app/l10n/app_localizations.dart'; // <-- 1. IMPORT LOCALIZATIONS

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final String _nickname = "Anuj";

  final List<Widget> _pages = [
    const BasicInfoPage(),
    const StatsPage(),
    const OfflineMapPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the AppLocalizations instance
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // --- 2. REPLACE HARDCODED TEXT ---
        title: Text(l10n.welcomeNickname(_nickname)), // <-- USE KEY
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotPage()),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: l10n.chatWithUs, // <-- USE KEY
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.sosAlertTriggered), // <-- USE KEY
                  backgroundColor: AppColors.error,
                ),
              );
            },
            icon: const Icon(Icons.sos_rounded, color: AppColors.error, size: 30),
            tooltip: l10n.sosAlert, // <-- USE KEY
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildNavigationControls(l10n), // <-- Pass l10n down
          const Divider(height: 1, thickness: 1, color: AppColors.surface),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. UPDATE THIS WIDGET TO ACCEPT AND USE l10n ---
  Widget _buildNavigationControls(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.person_outline, label: l10n.basicInfo, index: 0),
          _buildNavItem(icon: Icons.pie_chart_outline, label: l10n.stats, index: 1),
          _buildNavItem(icon: Icons.map_outlined, label: l10n.map, index: 2),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    // This widget doesn't need changes as it just displays the label it's given
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}