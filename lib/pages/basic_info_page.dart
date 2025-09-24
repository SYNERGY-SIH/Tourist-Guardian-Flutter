import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:my_app/l10n/app_localizations.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  // Placeholder data remains the same
  String touristId = "TRV-1234-5678-ABCD";
  String groupId = "GRP-9876-5432-EFGH";
  List<String> emergencyContacts = ["Mom: 9876543210"];
  List<String> placesToVisit = ["Guwahati, Assam", "Shillong, Meghalaya", "Dimapur, Assam"];
  int duration = 5;
  List<String> groupMembers = ["Ganesh Singh", "Suhani Singh"];
  String bandId = "TRK-72C-XYZ";
  double batteryLevel = 0.82;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            title: l10n.identification,
            icon: Icons.badge_outlined,
            children: [
              _buildInfoRow(title: l10n.touristId, content: touristId),
              _buildInfoRow(title: l10n.groupId, content: groupId),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: l10n.tripDetails,
            icon: Icons.map_outlined,
            children: [
              _buildInfoRow(title: l10n.duration, content: l10n.durationInDays(duration.toString())),
              const Divider(height: 24),
              _buildInfoList(title: l10n.placesToVisit, items: placesToVisit),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: l10n.contactsAndGroup,
            icon: Icons.people_outline,
            children: [
              _buildInfoList(title: l10n.emergencyContacts, items: emergencyContacts),
              const Divider(height: 24),
              _buildInfoList(title: l10n.groupMembers, items: groupMembers),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: l10n.yourBand,
            icon: Icons.sensors_outlined,
            children: [
              _buildInfoRow(title: l10n.bandId, content: bandId),
              const Divider(height: 24),
              _buildBatteryInfo(l10n.batteryLevel, batteryLevel),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text(l10n.editInformation),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

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

  Widget _buildBatteryInfo(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.background,
                  color: value > 0.2 ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${(value * 100).toInt()}%",
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14),
            )
          ],
        ),
      ],
    );
  }

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
        )),
      ],
    );
  }
}