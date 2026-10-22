import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_controller.dart';
import 'summary_screen.dart';

/// Màn hình Bảo hiểm Y tế - Bắt buộc chọn 1 trong 3 tuyến
/// Tính giảm giá theo Luật BHYT Việt Nam (sửa đổi 2024):
///   - Đúng tuyến / Cấp cứu / Giấy chuyển viện: BHYT chi trả 80%
///   - Trái tuyến: BHYT chi trả 60%
///   - Không có BHYT: Bệnh nhân trả 100%
class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text(
          'Bảo hiểm Y tế',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================== HEADER ===================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0056D2), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.health_and_safety, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xác nhận BHYT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chọn tuyến BHYT để áp dụng mức giảm giá theo quy định',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================== BẮT BUỘC CHỌN 1 TRONG 3 ===================
            const Text(
              'Chọn loại BHYT (bắt buộc)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Theo Luật BHYT Việt Nam (sửa đổi 2024)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),

            // === Option 1: Đúng tuyến (80%) ===
            Obx(() => _InsuranceOptionCard(
                  isSelected: controller.selectedInsurance.value == InsuranceOption.dungTuyen,
                  icon: Icons.verified,
                  iconColor: const Color(0xFF059669),
                  title: 'Đúng tuyến / Cấp cứu / Giấy chuyển viện',
                  subtitle: 'BHYT chi trả 80% chi phí khám bệnh',
                  discountLabel: '- 80%',
                  discountColor: const Color(0xFF059669),
                  onTap: () => controller.setInsuranceOption(InsuranceOption.dungTuyen),
                )),

            const SizedBox(height: 12),

            // === Option 2: Trái tuyến (60%) ===
            Obx(() => _InsuranceOptionCard(
                  isSelected: controller.selectedInsurance.value == InsuranceOption.traiTuyen,
                  icon: Icons.swap_horiz,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Trái tuyến',
                  subtitle: 'BHYT chi trả 60% chi phí khám bệnh',
                  discountLabel: '- 60%',
                  discountColor: const Color(0xFFF59E0B),
                  onTap: () => controller.setInsuranceOption(InsuranceOption.traiTuyen),
                )),

            const SizedBox(height: 12),

            // === Option 3: Không có BHYT (0%) ===
            Obx(() => _InsuranceOptionCard(
                  isSelected: controller.selectedInsurance.value == InsuranceOption.khongCoBHYT,
                  icon: Icons.cancel_outlined,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Không có BHYT',
                  subtitle: 'Bệnh nhân thanh toán 100% chi phí',
                  discountLabel: '100%',
                  discountColor: const Color(0xFFEF4444),
                  onTap: () => controller.setInsuranceOption(InsuranceOption.khongCoBHYT),
                )),

            const SizedBox(height: 24),

            // =================== BẢNG CHI PHÍ DỰ KIẾN (REAL-TIME) ===================
            Obx(() {
              if (controller.selectedInsurance.value == null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Vui lòng chọn loại BHYT để xem chi phí dự kiến',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final formatter = NumberFormat('#,###', 'vi_VN');
              final originalCost = controller.totalOriginalCost;
              final discount = controller.insuranceDiscount;
              final payable = controller.totalBookingCost;
              final rate = (controller.insuranceRate * 100).round();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long, size: 20, color: Color(0xFF0056D2)),
                        SizedBox(width: 8),
                        Text(
                          'Chi phí dự kiến',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tiền khám gốc
                    _buildCostRow('Tiền khám gốc', '${formatter.format(originalCost)}đ'),
                    
                    const SizedBox(height: 12),
                    
                    // BHYT chi trả
                    if (discount > 0) ...[
                      _buildCostRow(
                        'BHYT chi trả ($rate%)',
                        '- ${formatter.format(discount)}đ',
                        valueColor: const Color(0xFF059669),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Divider
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tổng tiền BN phải thanh toán
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BN thanh toán',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${formatter.format(payable)}đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF0056D2),
                          ),
                        ),
                      ],
                    ),

                    // Ghi chú nếu có BHYT
                    if (discount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Color(0xFF059669)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bạn tiết kiệm ${formatter.format(discount)}đ nhờ BHYT!',
                                style: const TextStyle(
                                  color: Color(0xFF059669),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // =================== BH TƯ NHÂN (TÙY CHỌN) ===================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Obx(() => CheckboxListTile(
                    title: const Text('Bảo hiểm bảo lãnh viện phí (Tư nhân)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Dai-ichi, Manulife, BaoViet...', style: TextStyle(fontSize: 12)),
                    activeColor: Colors.blue,
                    value: controller.hasPrivateInsurance.value,
                    onChanged: (value) {
                      controller.hasPrivateInsurance.value = value ?? false;
                    },
                  )),
            ),
            
            const SizedBox(height: 32),
            
            // =================== BUTTON TIẾP TỤC ===================
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.selectedInsurance.value != null
                    ? () {
                        controller.addCurrentBookingToItems();
                        Get.to(() => const SummaryScreen());
                      }
                    : null, // Disable nếu chưa chọn BHYT
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  controller.selectedInsurance.value != null ? 'Tiếp tục' : 'Vui lòng chọn loại BHYT',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: valueColor),
        ),
      ],
    );
  }
}

/// Widget cho mỗi lựa chọn BHYT (radio card style)
class _InsuranceOptionCard extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String discountLabel;
  final Color discountColor;
  final VoidCallback onTap;

  const _InsuranceOptionCard({
    required this.isSelected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.discountLabel,
    required this.discountColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? discountColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? discountColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: discountColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? discountColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: discountColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? discountColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Discount badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: discountColor.withOpacity(isSelected ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                discountLabel,
                style: TextStyle(
                  color: discountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
