import 'package:flutter/material.dart';

class SearchProfileScreen extends StatefulWidget {
  const SearchProfileScreen({Key? key}) : super(key: key);

  @override
  State<SearchProfileScreen> createState() => _SearchProfileScreenState();
}

class _SearchProfileScreenState extends State<SearchProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1 Controllers
  final _maBenhNhanController = TextEditingController();

  // Tab 2 Controllers
  final _hoTenLotController = TextEditingController();
  final _tenController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _namSinhController = TextEditingController();
  int? _gioiTinh;
  String? _quocGia = 'Việt Nam';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maBenhNhanController.dispose();
    _hoTenLotController.dispose();
    _tenController.dispose();
    _soDienThoaiController.dispose();
    _namSinhController.dispose();
    super.dispose();
  }

  void _searchByCode() {
    if (_maBenhNhanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã người bệnh')));
      return;
    }
    // TODO: Call API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tìm kiếm...')));
  }

  void _searchByInfo() {
    if (_hoTenLotController.text.isEmpty || _tenController.text.isEmpty || _soDienThoaiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin bắt buộc')));
      return;
    }
    // TODO: Call API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tìm kiếm...')));
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu hồ sơ'),
        backgroundColor: const Color(0xFF0056A6), // AppColors.primary
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Nhập mã người bệnh'),
            Tab(text: 'Quên hồ sơ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Nhập mã
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nhập mã người bệnh để tìm kiếm hồ sơ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn có thể tìm mã người bệnh (VD: N24-XXXXX) trên phiếu khám bệnh, biên lai thu tiền.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _maBenhNhanController,
                        decoration: const InputDecoration(
                          hintText: 'N24-XXXXX',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _searchByCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Tìm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab 2: Quên hồ sơ
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField('Họ tên lót', _hoTenLotController, isRequired: true),
                _buildTextField('Tên', _tenController, isRequired: true),
                _buildTextField('Số điện thoại', _soDienThoaiController, isRequired: true, keyboardType: TextInputType.phone),
                const Text('Giới tính *'),
                Row(
                  children: [
                    Radio<int>(value: 1, groupValue: _gioiTinh, onChanged: (val) => setState(() => _gioiTinh = val)),
                    const Text('Nam'),
                    Radio<int>(value: 0, groupValue: _gioiTinh, onChanged: (val) => setState(() => _gioiTinh = val)),
                    const Text('Nữ'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Năm sinh (YYYY)', _namSinhController, isRequired: true, keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Quốc gia', border: OutlineInputBorder(), isDense: true),
                  value: _quocGia,
                  items: ['Việt Nam', 'Khác'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _quocGia = val),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF0056A6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Quét CCCD', style: TextStyle(color: Color(0xFF0056A6))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _searchByInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056A6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tìm hồ sơ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
