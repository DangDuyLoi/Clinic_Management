import 'package:flutter/foundation.dart';
import '../models/administrative_unit.dart';
import '../repositories/address_repository.dart';

/// Controller quản lý logic chuỗi cascading 4 cấp cho địa giới hành chính:
/// Quốc gia -> Tỉnh/Thành -> Quận/Huyện -> Phường/Xã
class AddressCascadingController extends ChangeNotifier {
  final IAddressRepository _repository;

  AddressCascadingController(this._repository);

  // ===========================================================================
  // STATE CÁC GIÁ TRỊ ĐANG CHỌN
  // ===========================================================================
  AdministrativeUnit? selectedCountry;
  AdministrativeUnit? selectedProvince;
  AdministrativeUnit? selectedDistrict;
  AdministrativeUnit? selectedWard;

  // ===========================================================================
  // DANH SÁCH LỰA CHỌN CỦA TỪNG CẤP
  // ===========================================================================
  List<AdministrativeUnit> countries = [];
  List<AdministrativeUnit> provinces = [];
  List<AdministrativeUnit> districts = [];
  List<AdministrativeUnit> wards = [];

  // ===========================================================================
  // TRẠNG THÁI TẢI (LOADING STATES)
  // ===========================================================================
  bool isLoadingCountries = false;
  bool isLoadingProvinces = false;
  bool isLoadingDistricts = false;
  bool isLoadingWards = false;

  // ===========================================================================
  // GETTERS KIỂM SOÁT ENABLE / DISABLE CÁC DROPDOWN CẤP DƯỚI
  // ===========================================================================
  bool get isProvinceEnabled =>
      selectedCountry != null && provinces.isNotEmpty && !isLoadingProvinces;

  bool get isDistrictEnabled =>
      selectedProvince != null && districts.isNotEmpty && !isLoadingDistricts;

  bool get isWardEnabled =>
      selectedDistrict != null && wards.isNotEmpty && !isLoadingWards;

  // ===========================================================================
  // CÁC HÀM XỬ LÝ KHỞI TẠO VÀ CHUỖI CASCADING
  // ===========================================================================

  /// Khởi tạo dữ liệu ban đầu, có hỗ trợ truyền giá trị mặc định/sẵn có khi Edit
  Future<void> initialize({
    String defaultCountry = 'Việt Nam',
    String? defaultProvince,
    String? defaultDistrict,
    String? defaultWard,
  }) async {
    isLoadingCountries = true;
    notifyListeners();

    try {
      countries = await _repository.getCountries();
    } catch (_) {
      countries = [];
    } finally {
      isLoadingCountries = false;
    }

    if (countries.isEmpty) {
      notifyListeners();
      return;
    }

    // Chọn Quốc gia ban đầu
    final initialCountry = countries.firstWhere(
      (c) => c.name == defaultCountry,
      orElse: () => countries.first,
    );
    selectedCountry = initialCountry;

    // Tải danh sách Tỉnh/Thành
    isLoadingProvinces = true;
    notifyListeners();
    try {
      provinces = await _repository.getProvinces(initialCountry.name);
    } catch (_) {
      provinces = [];
    } finally {
      isLoadingProvinces = false;
    }

    // Nếu có Tỉnh/Thành mặc định
    if (defaultProvince != null && defaultProvince.isNotEmpty) {
      final foundProv = provinces.where((p) => p.name == defaultProvince);
      if (foundProv.isNotEmpty) {
        selectedProvince = foundProv.first;

        // Tải danh sách Quận/Huyện
        isLoadingDistricts = true;
        notifyListeners();
        try {
          districts = await _repository.getDistricts(
            initialCountry.name,
            selectedProvince!.name,
          );
        } catch (_) {
          districts = [];
        } finally {
          isLoadingDistricts = false;
        }

        // Nếu có Quận/Huyện mặc định
        if (defaultDistrict != null && defaultDistrict.isNotEmpty) {
          final foundDist = districts.where((d) => d.name == defaultDistrict);
          if (foundDist.isNotEmpty) {
            selectedDistrict = foundDist.first;

            // Tải danh sách Phường/Xã
            isLoadingWards = true;
            notifyListeners();
            try {
              wards = await _repository.getWards(
                initialCountry.name,
                selectedDistrict!.name,
              );
            } catch (_) {
              wards = [];
            } finally {
              isLoadingWards = false;
            }

            // Nếu có Phường/Xã mặc định
            if (defaultWard != null && defaultWard.isNotEmpty) {
              final foundWard = wards.where((w) => w.name == defaultWard);
              if (foundWard.isNotEmpty) {
                selectedWard = foundWard.first;
              }
            }
          }
        }
      }
    }

    notifyListeners();
  }

  /// Khi thay đổi Quốc gia: Xóa toàn bộ Tỉnh, Huyện, Xã đã chọn
  Future<void> selectCountry(AdministrativeUnit? country) async {
    if (selectedCountry == country) return;

    selectedCountry = country;
    selectedProvince = null;
    selectedDistrict = null;
    selectedWard = null;
    provinces = [];
    districts = [];
    wards = [];

    if (country != null) {
      isLoadingProvinces = true;
      notifyListeners();
      try {
        provinces = await _repository.getProvinces(country.name);
      } catch (_) {
        provinces = [];
      } finally {
        isLoadingProvinces = false;
      }
    }
    notifyListeners();
  }

  /// Khi thay đổi Tỉnh/Thành: Xóa toàn bộ Quận/Huyện và Phường/Xã đã chọn
  Future<void> selectProvince(AdministrativeUnit? province) async {
    if (selectedProvince == province) return;

    selectedProvince = province;
    selectedDistrict = null;
    selectedWard = null;
    districts = [];
    wards = [];

    if (province != null && selectedCountry != null) {
      isLoadingDistricts = true;
      notifyListeners();
      try {
        districts = await _repository.getDistricts(
          selectedCountry!.name,
          province.name,
        );
      } catch (_) {
        districts = [];
      } finally {
        isLoadingDistricts = false;
      }
    }
    notifyListeners();
  }

  /// Khi thay đổi Quận/Huyện: Xóa Phường/Xã đã chọn
  Future<void> selectDistrict(AdministrativeUnit? district) async {
    if (selectedDistrict == district) return;

    selectedDistrict = district;
    selectedWard = null;
    wards = [];

    if (district != null && selectedCountry != null) {
      isLoadingWards = true;
      notifyListeners();
      try {
        wards = await _repository.getWards(
          selectedCountry!.name,
          district.name,
        );
      } catch (_) {
        wards = [];
      } finally {
        isLoadingWards = false;
      }
    }
    notifyListeners();
  }

  /// Khi thay đổi Phường/Xã
  void selectWard(AdministrativeUnit? ward) {
    selectedWard = ward;
    notifyListeners();
  }

  /// Kiểm tra xem đã chọn đầy đủ các cấp bắt buộc chưa
  bool get isValid =>
      selectedCountry != null &&
      selectedProvince != null &&
      selectedDistrict != null &&
      selectedWard != null;

  /// Chuỗi hiển thị địa chỉ hành chính đầy đủ (ví dụ: Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh, Việt Nam)
  String get formattedAddress {
    return [
      selectedWard?.name,
      selectedDistrict?.name,
      selectedProvince?.name,
      selectedCountry?.name,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }
}
