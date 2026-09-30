import 'package:flutter/material.dart';
import 'widgets/profile_type_bottom_sheet.dart';
import '../../services/patient_profile_service.dart';
import 'search_profile_screen.dart';
import 'create_profile_screen.dart';

class ProfileEmptyScreen extends StatefulWidget {
  const ProfileEmptyScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEmptyScreen> createState() => _ProfileEmptyScreenState();
}

class _ProfileEmptyScreenState extends State<ProfileEmptyScreen> {
  void _showProfileTypeBottomSheet(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProfileTypeBottomSheet(),
    ).then((value) async {
      if (value == 'search') {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchProfileScreen()),
        );
        if (mounted) setState(() {});
      } else if (value == 'create') {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
        );
        if (mounted) setState(() {});
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có hồ sơ đặt khám',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng tạo hồ sơ mới để bắt đầu đặt khám',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showProfileTypeBottomSheet(context),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Thêm mới hồ sơ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056A6), // AppColors.primary
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList() {
    final profiles = PatientProfileService.cachedProfiles;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF0056A6)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile['ho_chu_lot'] ?? ''} ${profile['ten'] ?? ''}'.trim(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text('Mã HS: ${profile['ma_ho_so'] ?? profile['id'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showProfileTypeBottomSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo thêm hồ sơ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProfiles = PatientProfileService.cachedProfiles.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ khám bệnh', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: hasProfiles ? _buildProfileList() : _buildEmptyState(),
    );
  }
}
