import 'package:flutter/material.dart';

import 'profile_empty_screen.dart'; // Just in case we need it, but we can just pop
import '../../services/patient_profile_service.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = PatientProfileService();
  bool _isLoading = false;

  // Controllers
  final _hoChuLotController = TextEditingController();
  final _tenController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _emailController = TextEditingController();
  final _cccdController = TextEditingController();
  final _hoChieuController = TextEditingController();
  final _soDinhDanhController = TextEditingController();
  final _soNhaController = TextEditingController();

  // Selected values
  DateTime? _ngaySinh;
  String? _danToc;
  int? _gioiTinh;
  String? _ngheNghiep;
  String? _quanHe;
  String? _quocGia;
  String? _tinhThanh;
  String? _phuongXa;

  @override
  void dispose() {
    _hoChuLotController.dispose();
    _tenController.dispose();
    _soDienThoaiController.dispose();
    _emailController.dispose();
    _cccdController.dispose();
    _hoChieuController.dispose();
    _soDinhDanhController.dispose();
    _soNhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Validate Dropdowns and Radios which are not directly handled by Form validation
      if (_ngaySinh == null || _gioiTinh == null || _tinhThanh == null || _phuongXa == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập đầy đủ các trường bắt buộc có dấu *')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        final data = {
          'ho_chu_lot': _hoChuLotController.text,
          'ten': _tenController.text,
          'ngay_sinh': '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}',
          'dan_toc': _danToc,
          'gioi_tinh': _gioiTinh,
          'nghe_nghiep': _ngheNghiep,
          'quan_he': _quanHe,
          'so_dien_thoai': _soDienThoaiController.text,
          'email': _emailController.text,
          'cccd': _cccdController.text,
          'ho_chieu': _hoChieuController.text,
          'so_dinh_danh': _soDinhDanhController.text,
          'quoc_gia': _quocGia,
          'tinh_thanh': _tinhThanh,
          'phuong_xa': _phuongXa,
          'so_nha': _soNhaController.text,
        };

        await _profileService.createProfile(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hồ sơ đã được tạo thành công!')),
          );
          Navigator.pop(context); // Go back after success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _ngaySinh) {
      setState(() {
        _ngaySinh = picked;
      });
    }
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0056A6),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
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
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          return null;
        } : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hồ sơ khám bệnh'),
        backgroundColor: const Color(0xFF0056A6),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                title: 'Thông tin cá nhân',
                children: [
                  _buildTextField('Họ và chữ lót', _hoChuLotController, isRequired: true),
                  _buildTextField('Tên người bệnh', _tenController, isRequired: true),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        child: Text(
                          _ngaySinh == null
                              ? 'Chọn ngày sinh'
                              : '${_ngaySinh!.day}/${_ngaySinh!.month}/${_ngaySinh!.year}',
                        ),
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Dân tộc', border: OutlineInputBorder(), isDense: true),
                    value: _danToc,
                    items: ['Kinh', 'Tày', 'Thái', 'Hoa', 'Khmer', 'Mường', 'Nùng', 'Khác']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _danToc = val),
                  ),
                  const SizedBox(height: 16),
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Nghề nghiệp', border: OutlineInputBorder(), isDense: true),
                    value: _ngheNghiep,
                    items: ['Học sinh/Sinh viên', 'Nhân viên văn phòng', 'Công nhân', 'Nội trợ', 'Hưu trí', 'Khác']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _ngheNghiep = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Quan hệ với chủ tài khoản', border: OutlineInputBorder(), isDense: true),
                    value: _quanHe,
                    items: ['Bản thân', 'Vợ/Chồng', 'Con', 'Bố/Mẹ', 'Khác']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _quanHe = val),
                  ),
                ],
              ),
              _buildCard(
                title: 'Thông tin liên lạc',
                children: [
                  _buildTextField('Số điện thoại', _soDienThoaiController, isRequired: true, keyboardType: TextInputType.phone),
                  _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                ],
              ),
              _buildCard(
                title: 'Giấy tờ định danh',
                children: [
                  _buildTextField('Số CCCD', _cccdController, keyboardType: TextInputType.number),
                  _buildTextField('Số Hộ chiếu', _hoChieuController),
                  _buildTextField('Số định danh cá nhân', _soDinhDanhController),
                ],
              ),
              _buildCard(
                title: 'Địa chỉ',
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Quốc gia', border: OutlineInputBorder(), isDense: true),
                    value: _quocGia,
                    items: ['Việt Nam', 'Khác']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _quocGia = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tỉnh/Thành *', border: OutlineInputBorder(), isDense: true),
                    value: _tinhThanh,
                    items: ['Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng'] // Example
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _tinhThanh = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Phường/Xã *', border: OutlineInputBorder(), isDense: true),
                    value: _phuongXa,
                    items: ['Phường 1', 'Phường 2', 'Phường 3'] // Example
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _phuongXa = val),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Số nhà/Đường/Khu phố', _soNhaController, isRequired: true),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056A6), // AppColors.primary
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('TẠO HỒ SƠ KHÁM BỆNH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
