import 'package:flutter/material.dart';
import '../../../../services/emr_service.dart';
import '../../../../core/app_colors.dart';

class TestResultsTab extends StatefulWidget {
  const TestResultsTab({Key? key}) : super(key: key);

  @override
  State<TestResultsTab> createState() => _TestResultsTabState();
}

class _TestResultsTabState extends State<TestResultsTab> {
  final EmrService _emrService = EmrService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadTestResults();
  }

  Future<void> _loadTestResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _emrService.fetchTestResults();
      if (mounted) {
        setState(() {
          _results = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  IconData _getIconForTest(String testName) {
    final lower = testName.toLowerCase();
    if (lower.contains('máu') || lower.contains('huyết') || lower.contains('tiểu')) {
      return Icons.bloodtype_outlined;
    } else if (lower.contains('tim') || lower.contains('ecg') || lower.contains('điện tâm đồ')) {
      return Icons.monitor_heart_outlined;
    } else if (lower.contains('siêu âm') || lower.contains('x-quang') || lower.contains('x quang')) {
      return Icons.document_scanner_outlined;
    } else if (lower.contains('nội soi')) {
      return Icons.camera_alt_outlined;
    }
    return Icons.biotech_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải kết quả cận lâm sàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTestResults,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTestResults,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.biotech, size: 64, color: Colors.blue[300]),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Chưa có dữ liệu cận lâm sàng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kết quả xét nghiệm, X-Quang, siêu âm sẽ\nhiển thị tại đây sau khi bạn khám.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTestResults,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _results[index];
          final testName = item['test_name'] as String? ?? 'Chỉ định CLS';
          final icon = _getIconForTest(testName);

          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.withOpacity(0.18)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng 1: Icon + Tên dịch vụ + Badge trạng thái
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Khoa: ${item['department']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status'] as String? ?? 'Đã có kết quả',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Dòng 2: Thông tin ngày & bác sĩ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            item['date'] as String? ?? '',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'BS: ${item['doctor']}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Dòng 3: Khung Kết quả chi tiết
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'Kết quả kết luận:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['result'] as String? ?? 'Đang cập nhật...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
