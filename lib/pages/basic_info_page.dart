import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({Key? key}) : super(key: key);

  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  // Placeholder data remains the same
  String touristId = "TRV-1234-5678-ABCD";
  String groupId = "GRP-9876-5432-EFGH";
  List<String> emergencyContacts = ["Mom: 9876543210", "Friend: 1234567890"];
  List<String> placesToVisit = ["Taj Mahal, Agra", "Red Fort, Delhi", "India Gate, Delhi"];
  int duration = 5;
  List<String> groupMembers = ["Jane Doe", "Peter Smith"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            title: "Identification",
            icon: Icons.badge_outlined,
            children: [
              _buildInfoRow(title: "Tourist ID", content: touristId),
              _buildInfoRow(title: "Group ID", content: groupId),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: "Trip Details",
            icon: Icons.map_outlined,
            children: [
              _buildInfoRow(title: "Duration", content: "$duration days"),
              const Divider(height: 24),
              _buildInfoList(title: "Places to Visit", items: placesToVisit),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: "Contacts & Group",
            icon: Icons.people_outline,
            children: [
              _buildInfoList(title: "Emergency Contacts", items: emergencyContacts),
              const Divider(height: 24),
              _buildInfoList(title: "Group Members", items: groupMembers),
            ],
          ),
          const SizedBox(height: 80), // Space for the FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to an edit screen
        },
        label: const Text("Edit Information"),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // A reusable card for a whole section
  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  // A reusable row for a single key-value info item
  Widget _buildInfoRow({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Flexible(
            child: Text(
              content,
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // A widget for displaying a list of items within a card
  Widget _buildInfoList({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 6, color: AppColors.primary),
              const SizedBox(width: 8),
              Flexible(child: Text(item, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14))),
            ],
          ),
        )).toList(),
      ],
    );
  }
}