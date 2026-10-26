import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import 'controllers/payment_tab_controller.dart';

/// Màn hình Thanh toán viện phí (Payment Screen)
/// Tách biệt hoàn toàn UI và Logic theo mô hình GetX
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final PaymentTabController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PaymentTabController>()
        ? Get.find<PaymentTabController>()
        : Get.put(PaymentTabController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPaymentData();
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Thanh toán viện phí',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.5,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pending_actions_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Chờ thanh toán'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Lịch sử'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          // Hiển thị CircularProgressIndicator khi isLoading là true
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu viện phí...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Nội dung 2 Tab khi đã tải xong dữ liệu
          return TabBarView(
            children: [
              // TAB 1: Phiếu chờ thanh toán
              _buildPendingBillsTab(controller),

              // TAB 2: Lịch sử thanh toán
              _buildPaymentHistoryTab(controller),
            ],
          );
        }),
      ),
    );
  }

  // ================= TAB 1: PHIẾU CHỜ THANH TOÁN =================
  Widget _buildPendingBillsTab(PaymentTabController controller) {
    if (controller.pendingBills.isEmpty) {
      // Empty State khi danh sách trống
      return RefreshIndicator(
        onRefresh: controller.fetchPaymentData,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 72,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Bạn không có khoản viện phí nào cần thanh toán',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tất cả các dịch vụ và đơn thuốc đã được thanh toán đầy đủ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchPaymentData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.pendingBills.length,
        itemBuilder: (context, index) {
          final bill = controller.pendingBills[index];
          return _buildPendingBillCard(bill, controller);
        },
      ),
    );
  }

  /// Card hiển thị chi tiết một phiếu viện phí chờ thanh toán
  Widget _buildPendingBillCard(
    Map<String, dynamic> bill,
    PaymentTabController controller,
  ) {
    final int maLuotKham = bill['ma_luot_kham'] ?? 0;
    final String ngayKham = bill['ngay_kham'] ?? '--/--/----';
    final String chuyenKhoa = bill['chuyen_khoa'] ?? 'Chưa xác định';
    final String bacSi = bill['bac_si'] ?? 'Bác sĩ phụ trách';

    final num tienKham = bill['tien_kham'] ?? 150000;
    final num tienDichVu = bill['tien_dich_Vu'] ?? bill['tien_dich_vu'] ?? 0;
    final num tienThuoc = bill['tien_thuoc'] ?? 0;
    final num tongTien = bill['tong_tien'] ?? (tienKham + tienDichVu + tienThuoc);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã lượt khám & Badge Chờ thanh toán
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lượt khám #$maLuotKham',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'Chờ thanh toán',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.8),
            const SizedBox(height: 12),

            // Ngày khám, Chuyên khoa, Bác sĩ
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Ngày khám:',
              value: ngayKham,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              label: 'Chuyên khoa:',
              value: chuyenKhoa,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Bác sĩ:',
              value: bacSi,
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildCostRow('Tiền khám', controller.formatCurrency(tienKham)),
                  const SizedBox(height: 6),
                  _buildCostRow('Tiền dịch vụ / CLS', controller.formatCurrency(tienDichVu)),
                  const SizedBox(height: 6),
                  _buildCostRow('Tiền thuốc', controller.formatCurrency(tienThuoc)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tổng tiền: In đậm, màu đỏ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Tổng tiền thanh toán:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  controller.formatCurrency(tongTien),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // In đậm, màu đỏ theo yêu cầu
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nút ElevatedButton "Thanh toán VNPay"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.payBill(maLuotKham),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Thanh toán VNPay',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 2: LỊCH SỬ THANH TOÁN =================
  Widget _buildPaymentHistoryTab(PaymentTabController controller) {
    if (controller.paymentHistory.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.fetchPaymentData,
        child: const Center(
          child: Text(
            'Chưa có lịch sử giao dịch thanh toán',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchPaymentData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.paymentHistory.length,
        itemBuilder: (context, index) {
          final history = controller.paymentHistory[index];
          return _buildHistoryCard(history, controller);
        },
      ),
    );
  }

  /// Card hiển thị chi tiết một giao dịch trong lịch sử thanh toán
  Widget _buildHistoryCard(
    Map<String, dynamic> history,
    PaymentTabController controller,
  ) {
    final String maGiaoDich = history['ma_giao_dich'] ?? 'N/A';
    final String thoiGianThanhToan = history['thoi_gian_thanh_toan'] ?? '--';
    final num tongTien = history['tong_tien'] ?? 0;
    final String trangThai = history['trang_thai'] ?? 'Thành công';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã giao dịch và Badge trạng thái màu xanh lá
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MÃ GIAO DỊCH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        maGiaoDich,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge màu xanh lá báo "Thành công" theo yêu cầu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Xanh lá nhạt
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E7D32),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trangThai,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32), // Xanh lá đậm
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.8),
            const SizedBox(height: 12),

            // Thời gian thanh toán
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Thời gian:',
              value: thoiGianThanhToan,
            ),
            const SizedBox(height: 8),

            // Tổng tiền
            Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tổng tiền:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  controller.formatCurrency(tongTien),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nút OutlinedButton "Xem biên lai" theo yêu cầu
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _showReceiptModal(history, controller),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.receipt_outlined, size: 18),
                label: const Text(
                  'Xem biên lai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BIÊN LAI CHI TIẾT (BOTTOM SHEET) =================
  void _showReceiptModal(Map<String, dynamic> history, PaymentTabController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo trên modal
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Dấu mộc icon thành công
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.done_all_rounded,
                  color: Color(0xFF2E7D32),
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'BIÊN LAI ĐIỆN TỬ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'HỆ THỐNG PHÒNG KHÁM HUIT CARE',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 12),

              _buildReceiptRow('Mã giao dịch', history['ma_giao_dich'] ?? 'N/A', isBold: true),
              const SizedBox(height: 8),
              _buildReceiptRow('Thời gian thanh toán', history['thoi_gian_thanh_toan'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildReceiptRow('Phương thức', history['phuong_thuc'] ?? 'VNPay'),
              const SizedBox(height: 8),
              _buildReceiptRow('Chuyên khoa', history['chuyen_khoa'] ?? 'Khoa khám bệnh'),
              const SizedBox(height: 8),
              _buildReceiptRow('Bác sĩ điều trị', history['bac_si'] ?? 'Bác sĩ chuyên khoa'),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),

              // Tổng cộng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Tổng tiền đã thanh toán:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    controller.formatCurrency(history['tong_tien'] ?? 0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ================= REUSABLE WIDGETS =================
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
