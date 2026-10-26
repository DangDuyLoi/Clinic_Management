import 'package:flutter/material.dart';
import '../controllers/address_cascading_controller.dart';
import '../models/administrative_unit.dart';

/// Widget chọn địa giới hành chính 4 cấp (Quốc gia, Tỉnh/Thành, Quận/Huyện, Phường/Xã)
/// Đảm bảo tính nhất quán dữ liệu, tự động vô hiệu hóa (disabled) cấp dưới và xóa dữ liệu cũ.
class CascadingAddressPicker extends StatelessWidget {
  final AddressCascadingController controller;
  final bool isRequired;

  const CascadingAddressPicker({
    super.key,
    required this.controller,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final country = controller.selectedCountry;
        final isVN = country == null || country.name.contains('Việt Nam');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. QUỐC GIA
            _buildDropdownField(
              key: ValueKey('country_${controller.selectedCountry?.id}'),
              label: 'Quốc gia',
              selectedValue: controller.selectedCountry,
              items: controller.countries,
              isLoading: controller.isLoadingCountries,
              isEnabled: true,
              hintText: 'Chọn Quốc gia',
              onChanged: (val) => controller.selectCountry(val),
            ),
            const SizedBox(height: 16),

            // 2. TỈNH / THÀNH PHỐ
            _buildDropdownField(
              key: ValueKey('province_${controller.selectedCountry?.id}_${controller.selectedProvince?.id}'),
              label: isVN ? 'Tỉnh / Thành phố' : 'Tỉnh / Bang / Thành phố',
              selectedValue: controller.selectedProvince,
              items: controller.provinces,
              isLoading: controller.isLoadingProvinces,
              isEnabled: controller.isProvinceEnabled,
              hintText: controller.selectedCountry == null
                  ? 'Vui lòng chọn Quốc gia trước'
                  : (isVN ? 'Chọn Tỉnh / Thành phố' : 'Chọn Tỉnh / Bang'),
              onChanged: (val) => controller.selectProvince(val),
            ),
            const SizedBox(height: 16),

            // 3. QUẬN / HUYỆN
            _buildDropdownField(
              key: ValueKey('district_${controller.selectedProvince?.id}_${controller.selectedDistrict?.id}'),
              label: isVN ? 'Quận / Huyện' : 'Quận / Huyện / Hạt / Thị trấn',
              selectedValue: controller.selectedDistrict,
              items: controller.districts,
              isLoading: controller.isLoadingDistricts,
              isEnabled: controller.isDistrictEnabled,
              hintText: controller.selectedProvince == null
                  ? 'Vui lòng chọn Tỉnh/Thành trước'
                  : 'Chọn Quận / Huyện',
              onChanged: (val) => controller.selectDistrict(val),
            ),
            const SizedBox(height: 16),

            // 4. PHƯỜNG / XÃ
            _buildDropdownField(
              key: ValueKey('ward_${controller.selectedDistrict?.id}_${controller.selectedWard?.id}'),
              label: isVN ? 'Phường / Xã / Thị trấn' : 'Phường / Xã / Khu phố',
              selectedValue: controller.selectedWard,
              items: controller.wards,
              isLoading: controller.isLoadingWards,
              isEnabled: controller.isWardEnabled,
              hintText: controller.selectedDistrict == null
                  ? 'Vui lòng chọn Quận/Huyện trước'
                  : 'Chọn Phường / Xã',
              onChanged: (val) => controller.selectWard(val),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField({
    required Key key,
    required String label,
    required AdministrativeUnit? selectedValue,
    required List<AdministrativeUnit> items,
    required bool isLoading,
    required bool isEnabled,
    required String hintText,
    required ValueChanged<AdministrativeUnit?> onChanged,
  }) {
    final validValue = items.contains(selectedValue) ? selectedValue : null;

    return DropdownButtonFormField<AdministrativeUnit>(
      key: key,
      initialValue: validValue,
      isExpanded: true,
      menuMaxHeight: 350,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
        filled: !isEnabled,
        fillColor: !isEnabled ? Colors.grey.shade100 : Colors.transparent,
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: isEnabled
          ? items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList()
          : null,
      onChanged: isEnabled ? onChanged : null,
      validator: (val) {
        if (!isRequired) return null;
        if (isEnabled && val == null) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
    );
  }
}
