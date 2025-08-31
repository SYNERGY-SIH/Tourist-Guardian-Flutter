import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/pages/basic_info_page.dart';
import 'package:my_app/pages/stats_page.dart';
import 'package:my_app/pages/offline_map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final String _nickname = "John Doe"; // Placeholder

  // List of pages to be displayed
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Welcome, $_nickname"),
        // Prevent the default back button from appearing
        automaticallyImplyLeading: false,
        actions: [
          // New SOS Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                // Add your SOS logic here (e.g., show an alert, send a message)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("SOS Alert Triggered!"),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              icon: const Icon(Icons.sos_rounded, color: AppColors.error, size: 30),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // The new navigation controls section
          _buildNavigationControls(),
          const Divider(height: 1, thickness: 1, color: AppColors.surface),

          // The content area that switches between pages
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              // Add a key to the child to ensure AnimatedSwitcher detects a change
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

  // A widget for the new navigation bar
  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.person_outline, label: "Basic Info", index: 0),
          _buildNavItem(icon: Icons.pie_chart_outline, label: "Stats", index: 1),
          _buildNavItem(icon: Icons.map_outlined, label: "Map", index: 2),
        ],
      ),
    );
  }

  // A helper to build each navigation item
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
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