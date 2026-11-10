import 'package:flutter_test/flutter_test.dart';
import 'package:umc_care_clone/screens/profile/controllers/patient_profile_controller.dart';

void main() {
  group('MedicalValidators Unit Tests', () {
    test('1. BHYT Validation - Chuẩn 15 ký tự BHXH & Cross-check Tuổi', () {
      // Hợp lệ về cú pháp
      expect(MedicalValidators.validateBhyt('DN4011234567890'), isNull);
      expect(MedicalValidators.validateBhyt('GD4791234567890'), isNull);
      expect(MedicalValidators.validateBhyt('TE1011234567890', patientAge: 3), isNull); // Trẻ 3 tuổi dùng TE -> Hợp lệ
      expect(MedicalValidators.validateBhyt('HS4011234567890', patientAge: 12), isNull); // Học sinh 12 tuổi dùng HS -> Hợp lệ

      // LỖ HỔNG ĐÃ FIX: Sinh năm 1995 (29-31 tuổi) nhập mã BHYT HS -> BỊ TỪ CHỐI
      expect(
        MedicalValidators.validateBhyt('HS4011234567890', patientAge: 31, birthYear: 1995),
        contains('chỉ áp dụng cho học sinh từ 6 đến 18 tuổi'),
      );

      // Bệnh nhân 10 tuổi nhập mã TE -> BỊ TỪ CHỐI
      expect(
        MedicalValidators.validateBhyt('TE1011234567890', patientAge: 10),
        contains('chỉ dành cho trẻ em dưới 6 tuổi'),
      );

      // Bệnh nhân 60 tuổi nhập mã SV (Sinh viên) -> BỊ TỪ CHỐI
      expect(
        MedicalValidators.validateBhyt('SV4011234567890', patientAge: 60),
        contains('chỉ áp dụng cho sinh viên từ 18 đến 30 tuổi'),
      );

      // Không hợp lệ về cú pháp
      expect(MedicalValidators.validateBhyt('XX4011234567890'), contains('không thuộc danh mục'));
      expect(MedicalValidators.validateBhyt('DN6011234567890'), contains('mức hưởng, phải là số từ 1 đến 5'));
      expect(MedicalValidators.validateBhyt('DN4991234567890'), contains('mã tỉnh cấp thẻ'));
      expect(MedicalValidators.validateBhyt('DN4011234'), contains('chính xác 15 ký tự'));
    });

    test('2. Vietnamese Phone Validation - Chặn đứng đầu 01', () {
      // Hợp lệ
      expect(MedicalValidators.validatePhone('0901234567'), isNull);
      expect(MedicalValidators.validatePhone('0388123456'), isNull);
      expect(MedicalValidators.validatePhone('+84901234567'), isNull);
      expect(MedicalValidators.validatePhone('+84388123456'), isNull);

      // LỖ HỔNG ĐÃ FIX: Số điện thoại đầu 01 bị chặn đứng
      expect(MedicalValidators.validatePhone('0123456789'), contains('Đầu số 01 đã ngừng hoạt động từ năm 2018'));
      expect(MedicalValidators.validatePhone('01681234567'), contains('Đầu số 01 đã ngừng hoạt động từ năm 2018'));
      expect(MedicalValidators.validatePhone('+84123456789'), contains('Đầu số 01 đã ngừng hoạt động từ năm 2018'));
      expect(MedicalValidators.validatePhone('0241234567'), contains('không đúng định dạng'));
      expect(MedicalValidators.validatePhone('09012345'), contains('không đúng định dạng'));
    });

    test('3. CCCD Validation - Ràng buộc 12 số & Ngoại lệ < 14 tuổi', () {
      expect(MedicalValidators.validateCccd('', isUnder14: false), contains('bắt buộc phải nhập số CCCD'));
      expect(MedicalValidators.validateCccd('001098123456', isUnder14: false), isNull);
      expect(MedicalValidators.validateCccd('001098123', isUnder14: false), contains('đúng 12 chữ số'));

      expect(MedicalValidators.validateCccd('', isUnder14: true), isNull);
      expect(MedicalValidators.validateCccd(null, isUnder14: true), isNull);
    });
  });

  group('PatientProfileController State & Logic Tests', () {
    late PatientProfileController controller;

    setUp(() {
      controller = PatientProfileController();
    });

    test('Bóc tách CCCD Nam Thế kỷ 20 (1998) & Tự động khóa trường', () {
      controller.parseCccdInfo('001098123456');

      expect(controller.gender.value, equals(1)); // Nam
      expect(controller.birthYear.value, equals(1998));
      expect(controller.isCccdLocked.value, isTrue);
      expect(controller.cccdHelperText.value, contains('Nam, Năm sinh 1998'));

      controller.setGender(0);
      expect(controller.gender.value, equals(1));

      controller.setBirthDate(DateTime(1950, 10, 25));
      expect(controller.birthDate.value!.year, equals(1998));
      expect(controller.birthDate.value!.month, equals(10));
      expect(controller.birthDate.value!.day, equals(25));
    });

    test('Bóc tách CCCD Nữ Thế kỷ 21 (2004) & Khóa', () {
      controller.parseCccdInfo('079304123456');

      expect(controller.gender.value, equals(0)); // Nữ
      expect(controller.birthYear.value, equals(2004));
      expect(controller.isCccdLocked.value, isTrue);
      expect(controller.cccdHelperText.value, contains('Nữ, Năm sinh 2004'));
    });

    test('Tự động Mở khóa (Unlock) khi người dùng xóa bớt CCCD', () {
      controller.parseCccdInfo('001098123456');
      expect(controller.isCccdLocked.value, isTrue);

      controller.parseCccdInfo('00109812345');
      expect(controller.isCccdLocked.value, isFalse);
      expect(controller.cccdHelperText.value, isEmpty);

      controller.setGender(0);
      expect(controller.gender.value, equals(0));
    });

    test('Tính toán chính xác Trẻ em < 14 tuổi', () {
      final now = DateTime.now();
      final sixYearsAgo = DateTime(now.year - 6, now.month, now.day);
      controller.setBirthDate(sixYearsAgo);

      expect(controller.isUnder14.value, isTrue);
      expect(controller.patientAge.value, equals(6));

      final twentyYearsAgo = DateTime(now.year - 20, now.month, now.day);
      controller.setBirthDate(twentyYearsAgo);

      expect(controller.isUnder14.value, isFalse);
      expect(controller.patientAge.value, equals(20));
    });
  });
}
