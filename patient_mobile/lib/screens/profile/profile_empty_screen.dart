import 'package:flutter/material.dart';
import '../../services/patient_profile_service.dart';
import 'create_profile_screen.dart';

class ProfileEmptyScreen extends StatefulWidget {
  const ProfileEmptyScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEmptyScreen> createState() => _ProfileEmptyScreenState();
}

class _ProfileEmptyScreenState extends State<ProfileEmptyScreen> {
  final PatientProfileService _profileService = PatientProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshProfiles();
  }

  Future<void> _refreshProfiles() async {
    setState(() => _isLoading = true);
    try {
      await PatientProfileService.loadProfiles();
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateProfileScreen(),
      ),
    );
    if (result == true) {
      await _refreshProfiles();
    }
  }

  Future<void> _navigateToEdit(Map<String, dynamic> profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProfileScreen(initialProfile: profile),
      ),
    );
    if (result == true) {
      await _refreshProfiles();
    }
  }

  Future<void> _confirmDeleteProfile(Map<String, dynamic> profile) async {
    final fullName = '${profile['ho_chu_lot'] ?? ''} ${profile['ten'] ?? ''}'.trim();
    final profileId = profile['ma_ho_so'] ?? profile['id'];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text('Xóa hồ sơ', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa hồ sơ khám bệnh của "$fullName" không?\n\nThao tác này sẽ xóa hồ sơ khỏi tài khoản của bạn.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa hồ sơ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _profileService.deleteProfile(profileId);
        await PatientProfileService.loadProfiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa hồ sơ của $fullName thành công!'),
              backgroundColor: const Color(0xFF0056A6),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_alt_1_outlined,
                size: 55,
                color: Color(0xFF0056A6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có hồ sơ khám bệnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng tạo hồ sơ để dễ dàng đặt lịch khám, theo dõi tiến trình và quản lý bệnh án.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Thêm mới hồ sơ', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(Map<String, dynamic> profile) {
    final fullName = '${profile['ho_chu_lot'] ?? ''} ${profile['ten'] ?? ''}'.trim().toUpperCase();
    final relationship = profile['quan_he']?.toString() ?? 'Bản thân';
    final isSelf = relationship == 'Bản thân';
    final maHoSo = profile['ma_ho_so'] ?? profile['id'] ?? 'N/A';
    final gender = profile['gioi_tinh'] == 1 ? 'Nam' : (profile['gioi_tinh'] == 0 ? 'Nữ' : 'Khác');
    final dob = profile['ngay_sinh']?.toString() ?? 'Chưa cập nhật';
    final phone = profile['so_dien_thoai']?.toString() ?? '';
    final address = [
      profile['so_nha'],
      profile['phuong_xa'],
      profile['quan_huyen'],
      profile['tinh_thanh']
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Name, Relationship Tag, Action Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelf ? const Color(0xFFE6F0FA) : const Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelf ? Icons.person : Icons.family_restroom,
                      color: isSelf ? const Color(0xFF0056A6) : const Color(0xFF16A34A),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isNotEmpty ? fullName : 'CHƯA ĐẶT TÊN',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelf
                                    ? const Color(0xFF0056A6).withOpacity(0.1)
                                    : const Color(0xFF16A34A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                relationship,
                                style: TextStyle(
                                  color: isSelf ? const Color(0xFF0056A6) : const Color(0xFF16A34A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mã HS: $maHoSo',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _navigateToEdit(profile);
                      } else if (val == 'delete') {
                        _confirmDeleteProfile(profile);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: Color(0xFF0056A6), size: 20),
                            SizedBox(width: 10),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            SizedBox(width: 10),
                            Text('Xóa hồ sơ', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              // Body info: Ngày sinh, Giới tính, SĐT, Địa chỉ
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(Icons.calendar_today_outlined, 'Ngày sinh', dob),
                  ),
                  Expanded(
                    child: _buildInfoItem(Icons.wc_outlined, 'Giới tính', gender),
                  ),
                ],
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoItem(Icons.phone_outlined, 'Số điện thoại', phone),
              ],
              if (address.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoItem(Icons.location_on_outlined, 'Địa chỉ', address),
              ],
              const SizedBox(height: 12),
              // Action buttons (Sửa & Xóa)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _navigateToEdit(profile),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Sửa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0056A6),
                      side: const BorderSide(color: Color(0xFF0056A6)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDeleteProfile(profile),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Xóa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(color: Colors.grey.shade600)),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = PatientProfileService.cachedProfiles;
    final hasProfiles = profiles.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ khám bệnh', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (hasProfiles)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF0056A6)),
              tooltip: 'Thêm mới hồ sơ',
              onPressed: _navigateToCreate,
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshProfiles,
              child: hasProfiles
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: profiles.length + 1,
                      itemBuilder: (context, index) {
                        if (index == profiles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToCreate,
                                icon: const Icon(Icons.add),
                                label: const Text('Tạo thêm hồ sơ mới', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0056A6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildProfileItem(profiles[index]);
                      },
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: _buildEmptyState(),
                      ),
                    ),
            ),
      floatingActionButton: hasProfiles
          ? FloatingActionButton(
              onPressed: _navigateToCreate,
              backgroundColor: const Color(0xFF0056A6),
              foregroundColor: Colors.white,
              tooltip: 'Thêm hồ sơ mới',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
