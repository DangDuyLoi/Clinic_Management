import 'package:flutter/material.dart';

import '../../core/constants/vietnam_administrative_data.dart';
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
  final _customPhuongXaController = TextEditingController();

  // Selected values
  DateTime? _ngaySinh;
  String _danToc = 'Kinh';
  int? _gioiTinh;
  String? _ngheNghiep;
  String _quanHe = 'Bản thân';
  String _quocGia = 'Việt Nam';
  String? _tinhThanh;
  String? _quanHuyen;
  String? _phuongXa;
  bool _isCustomPhuongXa = false;

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
    _customPhuongXaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Validate Dropdowns and Radios which are not directly handled by Form validation
      if (_ngaySinh == null || _gioiTinh == null || _tinhThanh == null || _quanHuyen == null || _phuongXa == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập đầy đủ các trường bắt buộc có dấu *')),
        );
        return;
      }

      final phuongXaFinal = _phuongXa ?? '';

      if (phuongXaFinal.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn Phường / Xã / Thị trấn')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final data = {
          'ho_chu_lot': _hoChuLotController.text.trim(),
          'ten': _tenController.text.trim(),
          'ngay_sinh': '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}',
          'dan_toc': _danToc,
          'gioi_tinh': _gioiTinh,
          'nghe_nghiep': _ngheNghiep,
          'quan_he': _quanHe,
          'so_dien_thoai': _soDienThoaiController.text.trim(),
          'email': _emailController.text.trim(),
          'cccd': _cccdController.text.trim(),
          'ho_chieu': _hoChieuController.text.trim(),
          'so_dinh_danh': _soDinhDanhController.text.trim(),
          'quoc_gia': _quocGia,
          'tinh_thanh': _tinhThanh,
          'quan_huyen': _quanHuyen,
          'phuong_xa': phuongXaFinal,
          'so_nha': _soNhaController.text.trim(),
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
      initialDate: DateTime(1995),
      firstDate: DateTime(1920),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
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
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableProvinces = VietnamAdministrativeData.getProvincesByCountry(_quocGia);

    final availableDistricts = _tinhThanh != null
        ? VietnamAdministrativeData.getDistricts(_quocGia, _tinhThanh)
        : <String>[];

    final availableWards = _quanHuyen != null
        ? VietnamAdministrativeData.getWards(_quocGia, _quanHuyen)
        : <String>[];

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
                              : '${_ngaySinh!.day.toString().padLeft(2, '0')}/${_ngaySinh!.month.toString().padLeft(2, '0')}/${_ngaySinh!.year}',
                        ),
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Dân tộc *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: VietnamAdministrativeData.ethnicGroups.contains(_danToc)
                        ? _danToc
                        : VietnamAdministrativeData.ethnicGroups.first,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: VietnamAdministrativeData.ethnicGroups
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _danToc = val ?? 'Kinh'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Giới tính *', style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: _gioiTinh,
                        onChanged: (val) => setState(() => _gioiTinh = val),
                      ),
                      const Text('Nam'),
                      const SizedBox(width: 20),
                      Radio<int>(
                        value: 0,
                        groupValue: _gioiTinh,
                        onChanged: (val) => setState(() => _gioiTinh = val),
                      ),
                      const Text('Nữ'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Nghề nghiệp',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: VietnamAdministrativeData.occupations.contains(_ngheNghiep)
                        ? _ngheNghiep
                        : null,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: VietnamAdministrativeData.occupations
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _ngheNghiep = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Quan hệ với chủ tài khoản *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: VietnamAdministrativeData.relationships.contains(_quanHe)
                        ? _quanHe
                        : VietnamAdministrativeData.relationships.first,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: VietnamAdministrativeData.relationships
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _quanHe = val ?? 'Bản thân'),
                  ),
                ],
              ),
              _buildCard(
                title: 'Thông tin liên lạc',
                children: [
                  _buildTextField(
                    'Số điện thoại',
                    _soDienThoaiController,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              _buildCard(
                title: 'Giấy tờ định danh',
                children: [
                  _buildTextField(
                    'Số CCCD (Căn cước công dân)',
                    _cccdController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField('Số Hộ chiếu', _hoChieuController),
                  _buildTextField('Số định danh cá nhân', _soDinhDanhController),
                ],
              ),
              _buildCard(
                title: 'Địa chỉ thường trú',
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Quốc gia *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: VietnamAdministrativeData.countries.contains(_quocGia)
                        ? _quocGia
                        : VietnamAdministrativeData.countries.first,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: VietnamAdministrativeData.countries
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _quocGia = val ?? 'Việt Nam';
                        _tinhThanh = null;
                        _quanHuyen = null;
                        _phuongXa = null;
                        _isCustomPhuongXa = false;
                        _customPhuongXaController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: _quocGia == 'Việt Nam'
                          ? 'Tỉnh / Thành phố *'
                          : 'Tỉnh / Bang / Thành phố (${_quocGia.split(' ').first}) *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: availableProvinces.contains(_tinhThanh) ? _tinhThanh : null,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    hint: Text(_quocGia == 'Việt Nam'
                        ? 'Chọn Tỉnh / Thành phố'
                        : 'Chọn Tỉnh / Bang / Thành phố (${_quocGia.split(' ').first})'),
                    items: availableProvinces
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _tinhThanh = val;
                        _quanHuyen = null;
                        _phuongXa = null;
                        _isCustomPhuongXa = false;
                        _customPhuongXaController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: _quocGia == 'Việt Nam'
                          ? 'Quận / Huyện *'
                          : 'Quận / Huyện / Hạt / Thị trấn *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      hintText: _tinhThanh == null
                          ? 'Vui lòng chọn Tỉnh/Thành trước'
                          : 'Chọn Quận / Huyện',
                    ),
                    value: availableDistricts.contains(_quanHuyen) ? _quanHuyen : null,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: availableDistricts
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: _tinhThanh == null
                        ? null
                        : (val) {
                            setState(() {
                              _quanHuyen = val;
                              _phuongXa = null;
                              _isCustomPhuongXa = false;
                              _customPhuongXaController.clear();
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: _quocGia == 'Việt Nam'
                          ? 'Phường / Xã / Thị trấn *'
                          : 'Phường / Xã / Khu phố *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      hintText: _quanHuyen == null
                          ? 'Vui lòng chọn Quận/Huyện trước'
                          : 'Chọn Phường / Xã',
                    ),
                    value: availableWards.contains(_phuongXa) ? _phuongXa : null,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: availableWards
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: _quanHuyen == null
                        ? null
                        : (val) {
                            setState(() {
                              _phuongXa = val;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Số nhà, tên đường, tổ/khu phố/ấp/thôn *',
                    _soNhaController,
                    isRequired: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056A6),
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
                    : const Text(
                        'TẠO HỒ SƠ KHÁM BỆNH',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
