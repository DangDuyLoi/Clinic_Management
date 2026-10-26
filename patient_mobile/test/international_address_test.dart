import 'package:flutter_test/flutter_test.dart';
import 'package:umc_care_clone/core/address/data/international_address_data.dart';
import 'package:umc_care_clone/core/address/repositories/vietnam_address_repository.dart';

void main() {
  group('International Address Cascading Tests', () {
    final repo = VietnamAddressRepository();

    test('Trung Quốc cascading', () async {
      final provinces = await repo.getProvinces('Trung Quốc');
      expect(provinces.isNotEmpty, true);
      expect(provinces.any((p) => p.name.contains('Bắc Kinh')), true);
      expect(provinces.any((p) => p.name.contains('Thượng Hải')), true);
      expect(provinces.any((p) => p.name.contains('Quảng Đông')), true);

      final beijing = provinces.firstWhere((p) => p.name.contains('Bắc Kinh'));
      final districts = await repo.getDistricts('Trung Quốc', beijing.name);
      expect(districts.isNotEmpty, true);
      expect(districts.any((d) => d.name.contains('Triều Dương')), true);

      final chaoyang = districts.firstWhere((d) => d.name.contains('Triều Dương'));
      final wards = await repo.getWards('Trung Quốc', chaoyang.name);
      expect(wards.isNotEmpty, true);
      expect(wards.any((w) => w.name.contains('Tam Lý Đồn')), true);
    });

    test('Hoa Kỳ (Mỹ) cascading', () async {
      final provinces = await repo.getProvinces('Hoa Kỳ (Mỹ)');
      expect(provinces.isNotEmpty, true);
      expect(provinces.any((p) => p.name.contains('California')), true);

      final ca = provinces.firstWhere((p) => p.name.contains('California'));
      final districts = await repo.getDistricts('Hoa Kỳ (Mỹ)', ca.name);
      expect(districts.isNotEmpty, true);
      expect(districts.any((d) => d.name.contains('Quận Cam')), true);

      final oc = districts.firstWhere((d) => d.name.contains('Quận Cam'));
      final wards = await repo.getWards('Hoa Kỳ (Mỹ)', oc.name);
      expect(wards.isNotEmpty, true);
      expect(wards.any((w) => w.name.contains('Westminster')), true);
    });

    test('Nhật Bản cascading', () async {
      final provinces = await repo.getProvinces('Nhật Bản');
      expect(provinces.isNotEmpty, true);
      expect(provinces.any((p) => p.name.contains('Tokyo')), true);

      final tokyo = provinces.firstWhere((p) => p.name.contains('Tokyo'));
      final districts = await repo.getDistricts('Nhật Bản', tokyo.name);
      expect(districts.isNotEmpty, true);
      expect(districts.any((d) => d.name.contains('Shinjuku')), true);

      final shinjuku = districts.firstWhere((d) => d.name.contains('Shinjuku'));
      final wards = await repo.getWards('Nhật Bản', shinjuku.name);
      expect(wards.isNotEmpty, true);
      expect(wards.any((w) => w.name.contains('Kabukicho')), true);
    });
  });
}
