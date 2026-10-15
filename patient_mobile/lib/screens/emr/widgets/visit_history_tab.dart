import 'package:flutter/material.dart';
import '../../../../services/emr_service.dart';
import '../../../../core/app_colors.dart';
import 'visit_timeline_item.dart';

class VisitHistoryTab extends StatefulWidget {
  const VisitHistoryTab({Key? key}) : super(key: key);

  @override
  State<VisitHistoryTab> createState() => _VisitHistoryTabState();
}

class _VisitHistoryTabState extends State<VisitHistoryTab> {
  final EmrService _emrService = EmrService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisitHistory();
  }

  Future<void> _loadVisitHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _emrService.fetchVisitHistory();
      if (mounted) {
        setState(() {
          _visits = data;
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
              Text(
                'Không thể tải dữ liệu hồ sơ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadVisitHistory,
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

    if (_visits.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadVisitHistory,
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
                      child: Icon(Icons.medical_services_outlined, size: 64, color: Colors.blue[300]),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Chưa có lịch sử khám bệnh',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thông tin các đợt khám và đơn thuốc\nsẽ hiển thị tại đây sau khi hoàn tất phiên khám.',
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
      onRefresh: _loadVisitHistory,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          final visit = _visits[index];
          return VisitTimelineItem(
            date: visit['date'] as String,
            department: visit['department'] as String,
            doctor: visit['doctor'] as String?,
            room: visit['room'] as String?,
            diagnosis: visit['diagnosis'] as String,
            note: visit['note'] as String?,
            medications: (visit['medications'] as List).cast<Map<String, String>>(),
            isLast: index == _visits.length - 1,
          );
        },
      ),
    );
  }
}
