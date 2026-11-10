import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/address/controllers/address_cascading_controller.dart';
import '../../core/address/repositories/vietnam_address_repository.dart';
import '../../core/address/widgets/cascading_address_picker.dart';
import '../../services/auth_service.dart';
import '../../services/master_data_service.dart';
import '../../services/patient_profile_service.dart';
import 'controllers/patient_profile_controller.dart';

class CreateProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;
  const CreateProfileScreen({Key? key, this.initialProfile}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = PatientProfileService();
  late final AddressCascadingController _addressController;
  late final PatientProfileController _profileController;
  bool _isLoading = false;
  String? _userAccountPhone;

  bool get isEditing => widget.initialProfile != null;

  /// Danh sách quan hệ hợp lệ: Mỗi tài khoản chỉ được phép có duy nhất MỘT hồ sơ "Bản thân"
  List<String> get availableRelationships {
    final currentProfileId = widget.initialProfile?['ma_ho_so'] ?? widget.initialProfile?['id'];
    final hasSelf = PatientProfileService.cachedProfiles.any(
      (p) => p['quan_he'] == 'Bản thân' && (!isEditing || (p['ma_ho_so'] ?? p['id']) != currentProfileId),
    );
    if (hasSelf) {
      return MasterDataService.relationships.where((r) => r != 'Bản thân').toList();
    }
    return MasterDataService.relationships;
  }

  // Controllers
  final _hoChuLotController = TextEditingController();
  final _tenController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _nguoiLienHeKhanCapController = TextEditingController();
  final _emailController = TextEditingController();
  final _cccdController = TextEditingController();
  final _soTheBhytController = TextEditingController();
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
    _profileController = Get.put(PatientProfileController());
    _addressController = AddressCascadingController(VietnamAddressRepository());

    final rels = availableRelationships;
    if (!rels.contains(_quanHe)) {
      _quanHe = rels.first;
    }

    if (isEditing) {
      final p = widget.initialProfile!;
      _hoChuLotController.text = p['ho_chu_lot']?.toString() ?? '';
      _tenController.text = p['ten']?.toString() ?? '';
      _soDienThoaiController.text = p['so_dien_thoai']?.toString() ?? '';
      _nguoiLienHeKhanCapController.text = p['nguoi_lien_he_khan_cap']?.toString() ?? '';
      _emailController.text = p['email']?.toString() ?? '';
      _cccdController.text = p['cccd']?.toString() ?? '';
      _soTheBhytController.text = p['so_the_bhyt']?.toString() ?? '';
      _hoChieuController.text = p['ho_chieu']?.toString() ?? '';
      _soDinhDanhController.text = p['so_dinh_danh']?.toString() ?? '';
      _soNhaController.text = p['so_nha']?.toString() ?? '';

      if (p['ngay_sinh'] != null) {
        _ngaySinh = DateTime.tryParse(p['ngay_sinh'].toString());
      }
      if (p['dan_toc'] != null && p['dan_toc'].toString().isNotEmpty) {
        _danToc = p['dan_toc'].toString();
      }
      if (p['gioi_tinh'] != null) {
        _gioiTinh = int.tryParse(p['gioi_tinh'].toString());
      }
      if (p['nghe_nghiep'] != null) {
        _ngheNghiep = p['nghe_nghiep'].toString();
      }
      if (p['quan_he'] != null && p['quan_he'].toString().isNotEmpty) {
        _quanHe = p['quan_he'].toString();
      }

      _profileController.initFromExisting(p);

      _addressController.initialize(
        defaultCountry: p['quoc_gia']?.toString() ?? 'Việt Nam',
        defaultProvince: p['tinh_thanh']?.toString(),
        defaultDistrict: p['quan_huyen']?.toString(),
        defaultWard: p['phuong_xa']?.toString(),
      );
    } else {
      _addressController.initialize();
      _prefillPhone();
    }
  }

  Future<void> _prefillPhone() async {
    try {
      final phone = await AuthService().getUserPhone();
      if (phone != null && phone.isNotEmpty && mounted) {
        _userAccountPhone = phone;
        if (_quanHe == 'Bản thân' || _soDienThoaiController.text.isEmpty) {
          setState(() {
            _soDienThoaiController.text = phone;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _addressController.dispose();
    _hoChuLotController.dispose();
    _tenController.dispose();
    _soDienThoaiController.dispose();
    _nguoiLienHeKhanCapController.dispose();
    _emailController.dispose();
    _cccdController.dispose();
    _soTheBhytController.dispose();
    _hoChieuController.dispose();
    _soDinhDanhController.dispose();
    _soNhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
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
          'ngay_sinh':
              '${_ngaySinh!.year}-${_ngaySinh!.month.toString().padLeft(2, '0')}-${_ngaySinh!.day.toString().padLeft(2, '0')}',
          'dan_toc': _danToc,
          'gioi_tinh': _gioiTinh,
          'nghe_nghiep': _ngheNghiep,
          'quan_he': _quanHe,
          'so_dien_thoai': _soDienThoaiController.text.trim(),
          'nguoi_lien_he_khan_cap': _nguoiLienHeKhanCapController.text.trim().isEmpty
              ? null
              : _nguoiLienHeKhanCapController.text.trim(),
          'email': _emailController.text.trim(),
          'cccd': _cccdController.text.trim().isEmpty ? null : _cccdController.text.trim(),
          'so_the_bhyt': _soTheBhytController.text.trim().isEmpty ? null : _soTheBhytController.text.trim(),
          'ho_chieu': _hoChieuController.text.trim(),
          'so_dinh_danh': _soDinhDanhController.text.trim(),
          'quoc_gia': _addressController.selectedCountry?.name ?? 'Việt Nam',
          'tinh_thanh': _addressController.selectedProvince?.name,
          'quan_huyen': _addressController.selectedDistrict?.name,
          'phuong_xa': _addressController.selectedWard?.name,
          'so_nha': _soNhaController.text.trim(),
        };

        if (isEditing) {
          final profileId = widget.initialProfile!['ma_ho_so'] ?? widget.initialProfile!['id'];
          await _profileService.updateProfile(profileId, data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hồ sơ đã được cập nhật thành công!'),
                backgroundColor: Color(0xFF0056A6),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          await _profileService.createProfile(data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hồ sơ đã được tạo thành công!'),
                backgroundColor: Color(0xFF0056A6),
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
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
    // Nếu CCCD đã khóa, giới hạn chọn ngày tháng trong đúng Năm của CCCD
    final isLocked = _profileController.isCccdLocked.value;
    final lockedYear = _profileController.birthYear.value;

    DateTime firstDate = isLocked && lockedYear != null ? DateTime(lockedYear, 1, 1) : DateTime(1920);
    DateTime lastDate = isLocked && lockedYear != null
        ? (lockedYear == DateTime.now().year ? DateTime.now() : DateTime(lockedYear, 12, 31))
        : DateTime.now();

    DateTime initialDate = _ngaySinh ?? (isLocked && lockedYear != null ? DateTime(lockedYear, 1, 1) : DateTime(1995));
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isLocked ? 'CHỌN NGÀY VÀ THÁNG (NĂM $lockedYear CỐ ĐỊNH THEO CCCD)' : 'CHỌN NGÀY SINH',
    );

    if (picked != null) {
      _profileController.setBirthDate(picked);
      setState(() {
        _ngaySinh = _profileController.birthDate.value;
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
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? helperText,
    Color? helperColor,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          helperText: helperText,
          helperMaxLines: 2,
          helperStyle: helperColor != null ? TextStyle(color: helperColor, fontWeight: FontWeight.w500) : null,
        ),
        validator: validator ??
            (isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập $label';
                    }
                    return null;
                  }
                : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa hồ sơ' : 'Tạo hồ sơ khám bệnh'),
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
              // ----------------------------------------------------
              // 1. THÔNG TIN CÁ NHÂN
              // ----------------------------------------------------
              _buildCard(
                title: 'Thông tin cá nhân',
                children: [
                  _buildTextField('Họ và chữ lót', _hoChuLotController, isRequired: true),
                  _buildTextField('Tên người bệnh', _tenController, isRequired: true),

                  // TRƯỜNG NGÀY SINH (CÓ HIỆU ỨNG KHÓA THEO CCCD)
                  Obx(() {
                    final isLocked = _profileController.isCccdLocked.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày sinh *',
                            border: const OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: isLocked
                                ? const Tooltip(
                                    message: 'Năm sinh cố định theo số CCCD',
                                    child: Icon(Icons.lock, color: Color(0xFF0056A6), size: 20),
                                  )
                                : const Icon(Icons.calendar_today, size: 20),
                            helperText: isLocked
                                ? 'Năm sinh ${_profileController.birthYear.value} đã được xác thực cố định theo CCCD'
                                : (_profileController.isUnder14.value
                                    ? 'Bệnh nhân ${_profileController.patientAge.value} tuổi (Trẻ em dưới 14 tuổi)'
                                    : null),
                            helperStyle: TextStyle(
                              color: isLocked ? const Color(0xFF0056A6) : Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: Text(
                            _ngaySinh == null
                                ? 'Chọn ngày sinh'
                                : '${_ngaySinh!.day.toString().padLeft(2, '0')}/${_ngaySinh!.month.toString().padLeft(2, '0')}/${_ngaySinh!.year}',
                            style: TextStyle(
                              fontWeight: isLocked ? FontWeight.bold : FontWeight.normal,
                              color: isLocked ? const Color(0xFF0056A6) : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

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

                  // TRƯỜNG GIỚI TÍNH (CÓ HIỆU ỨNG KHÓA NẾU CÓ CCCD)
                  Obx(() {
                    final isLocked = _profileController.isCccdLocked.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Giới tính *', style: TextStyle(fontWeight: FontWeight.w500)),
                            if (isLocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock, size: 12, color: Color(0xFF0056A6)),
                                    SizedBox(width: 4),
                                    Text('Cố định theo CCCD',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF0056A6), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            ]
                          ],
                        ),
                        Row(
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: _gioiTinh,
                              onChanged: isLocked
                                  ? null
                                  : (val) {
                                      _profileController.setGender(val);
                                      setState(() => _gioiTinh = val);
                                    },
                            ),
                            Text('Nam', style: TextStyle(color: isLocked && _gioiTinh != 1 ? Colors.grey : Colors.black87)),
                            const SizedBox(width: 20),
                            Radio<int>(
                              value: 0,
                              groupValue: _gioiTinh,
                              onChanged: isLocked
                                  ? null
                                  : (val) {
                                      _profileController.setGender(val);
                                      setState(() => _gioiTinh = val);
                                    },
                            ),
                            Text('Nữ', style: TextStyle(color: isLocked && _gioiTinh != 0 ? Colors.grey : Colors.black87)),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Nghề nghiệp',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: MasterDataService.occupations.contains(_ngheNghiep) ? _ngheNghiep : null,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: MasterDataService.occupations
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _ngheNghiep = val),
                  ),
                  const SizedBox(height: 16),

                  // QUAN HỆ VỚI CHỦ TÀI KHOẢN (DUY NHẤT 1 HỒ SƠ 'BẢN THÂN')
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Quan hệ với chủ tài khoản *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: availableRelationships.contains(_quanHe) ? _quanHe : availableRelationships.first,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    items: availableRelationships
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _quanHe = val ?? availableRelationships.first;
                        // Nếu chọn 'Bản thân', tự động khôi phục SĐT tài khoản
                        if (_quanHe == 'Bản thân' && _userAccountPhone != null) {
                          _soDienThoaiController.text = _userAccountPhone!;
                        }
                      });
                    },
                  ),
                ],
              ),

              // ----------------------------------------------------
              // 2. THÔNG TIN LIÊN LẠC & NGƯỜI GIÁM HỘ (NGOẠI LỆ < 14 TUỔI)
              // ----------------------------------------------------
              _buildCard(
                title: 'Thông tin liên lạc',
                children: [
                  _buildTextField(
                    'Số điện thoại',
                    _soDienThoaiController,
                    isRequired: true,
                    readOnly: _quanHe == 'Bản thân',
                    keyboardType: TextInputType.phone,
                    prefixIcon: _quanHe == 'Bản thân'
                        ? const Icon(Icons.lock, size: 18, color: Color(0xFF0056A6))
                        : const Icon(Icons.phone),
                    helperText: _quanHe == 'Bản thân'
                        ? 'Hồ sơ Bản thân: Số điện thoại cố định theo tài khoản đăng nhập'
                        : null,
                    helperColor: const Color(0xFF0056A6),
                    validator: (v) => MedicalValidators.validatePhone(v, isRequired: true, fieldName: 'Số điện thoại'),
                  ),

                  // CẢNH BÁO & BẮT BUỘC SĐT NGƯỜI GIÁM HỘ KHI TRẺ EM < 14 TUỔI
                  Obx(() {
                    final under14 = _profileController.isUnder14.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (under14) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              border: Border.all(color: Colors.orange[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bệnh nhân dưới 14 tuổi: Bắt buộc cung cấp số điện thoại của cha mẹ hoặc người giám hộ hợp pháp.',
                                    style: TextStyle(fontSize: 12, color: Colors.orange[900], fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        _buildTextField(
                          under14 ? 'SĐT Cha mẹ / Người giám hộ' : 'SĐT Người liên hệ khẩn cấp (Tùy chọn)',
                          _nguoiLienHeKhanCapController,
                          isRequired: under14,
                          keyboardType: TextInputType.phone,
                          validator: (v) => MedicalValidators.validatePhone(
                            v,
                            isRequired: under14,
                            fieldName: under14 ? 'SĐT Cha mẹ / Người giám hộ' : 'SĐT Người liên hệ khẩn cấp',
                          ),
                          helperText: under14
                              ? 'Dành cho việc liên hệ cấp cứu & bảo hộ pháp lý khi khám bệnh'
                              : null,
                        ),
                      ],
                    );
                  }),

                  _buildTextField(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),

              // ----------------------------------------------------
              // 3. GIẤY TỜ ĐỊNH DANH & BẢO HIỂM Y TẾ
              // ----------------------------------------------------
              _buildCard(
                title: 'Giấy tờ định danh & Bảo hiểm Y tế',
                children: [
                  // Ô CCCD VỚI LOGIC BÓC TÁCH & KHÓA REACTIVE
                  Obx(() {
                    final under14 = _profileController.isUnder14.value;
                    final isLocked = _profileController.isCccdLocked.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          under14 ? 'Số CCCD (Không bắt buộc với trẻ < 14 tuổi)' : 'Số CCCD (Căn cước công dân)',
                          _cccdController,
                          isRequired: !under14,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.badge_outlined),
                          suffixIcon: isLocked
                              ? IconButton(
                                  icon: const Icon(Icons.lock_open, color: Colors.grey),
                                  tooltip: 'Xóa để mở khóa chọn lại ngày sinh/giới tính',
                                  onPressed: () {
                                    _cccdController.clear();
                                    _profileController.unlockCccd();
                                    setState(() {});
                                  },
                                )
                              : null,
                          onChanged: (val) {
                            _profileController.parseCccdInfo(val);
                            setState(() {
                              if (_profileController.birthDate.value != null) {
                                _ngaySinh = _profileController.birthDate.value;
                              }
                              if (_profileController.gender.value != null) {
                                _gioiTinh = _profileController.gender.value;
                              }
                            });
                          },
                          validator: (val) => MedicalValidators.validateCccd(val, isUnder14: under14),
                          helperText: _profileController.cccdHelperText.value.isNotEmpty
                              ? _profileController.cccdHelperText.value
                              : (_profileController.cccdErrorText.value ?? 'Nhập đủ 12 số để tự động nhận diện Giới tính & Năm sinh'),
                          helperColor: _profileController.cccdHelperText.value.isNotEmpty
                              ? const Color(0xFF0056A6)
                              : (_profileController.cccdErrorText.value != null ? Colors.red : null),
                        ),
                      ],
                    );
                  }),

                  // Ô NHẬP MÃ THẺ BẢO HIỂM Y TẾ (CÓ KIỂM TRA CHÉO ĐỘ TUỔI)
                  Obx(() {
                    return _buildTextField(
                      'Mã thẻ Bảo hiểm Y tế (BHYT)',
                      _soTheBhytController,
                      isRequired: false,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.health_and_safety_outlined),
                      validator: (v) => MedicalValidators.validateBhyt(
                        v,
                        patientAge: _profileController.patientAge.value,
                        birthYear: _profileController.birthYear.value,
                      ),
                      helperText: 'Gồm 15 ký tự (VD: DN4011234567890, GD4791234567890)',
                    );
                  }),

                  _buildTextField('Số Hộ chiếu', _hoChieuController),
                  _buildTextField('Số định danh cá nhân', _soDinhDanhController),
                ],
              ),

              // ----------------------------------------------------
              // 4. ĐỊA CHỈ THƯỜNG TRÚ
              // ----------------------------------------------------
              _buildCard(
                title: 'Địa chỉ thường trú',
                children: [
                  CascadingAddressPicker(controller: _addressController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Số nhà, tên đường, tổ/khu phố/ấp/thôn',
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
                    : Text(
                        isEditing ? 'LƯU THAY ĐỔI' : 'TẠO HỒ SƠ KHÁM BỆNH',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
