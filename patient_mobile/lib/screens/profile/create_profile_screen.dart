import 'package:flutter/material.dart';

import '../../core/address/controllers/address_cascading_controller.dart';
import '../../core/address/repositories/vietnam_address_repository.dart';
import '../../core/address/widgets/cascading_address_picker.dart';
import '../../services/master_data_service.dart';
import '../../services/patient_profile_service.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = PatientProfileService();
  late final AddressCascadingController _addressController;
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
  String _danToc = 'Kinh';
  int? _gioiTinh;
  String? _ngheNghiep;
  String _quanHe = 'Bản thân';

  @override
  void initState() {
    super.initState();
    _addressController = AddressCascadingController(VietnamAddressRepository());
    _addressController.initialize();
  }

  @override
  void dispose() {
    _addressController.dispose();
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
      // Validate Dropdowns, Radios and Address
      if (_ngaySinh == null || _gioiTinh == null || !_addressController.isValid) {
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
          'quoc_gia': _addressController.selectedCountry?.name ?? 'Việt Nam',
          'tinh_thanh': _addressController.selectedProvince?.name,
          'quan_huyen': _addressController.selectedDistrict?.name,
          'phuong_xa': _addressController.selectedWard?.name,
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
                    value: MasterDataService.ethnicGroups.contains(_danToc)
                        ? _danToc
                        : MasterDataService.ethnicGroups.first,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: MasterDataService.ethnicGroups
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
                    value: MasterDataService.occupations.contains(_ngheNghiep)
                        ? _ngheNghiep
                        : null,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: MasterDataService.occupations
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
                    value: MasterDataService.relationships.contains(_quanHe)
                        ? _quanHe
                        : MasterDataService.relationships.first,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: MasterDataService.relationships
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
                  CascadingAddressPicker(controller: _addressController),
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
