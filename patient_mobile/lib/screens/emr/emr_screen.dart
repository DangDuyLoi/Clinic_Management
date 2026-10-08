import 'package:flutter/material.dart';
import 'widgets/visit_history_tab.dart';
import 'widgets/test_results_tab.dart';
import '../../core/app_colors.dart';

class EmrScreen extends StatelessWidget {
  const EmrScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Hồ Sơ Bệnh Án', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            tabs: const [
              Tab(text: 'Lịch sử khám'),
              Tab(text: 'Kết quả CLS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            VisitHistoryTab(),
            TestResultsTab(),
          ],
        ),
      ),
    );
  }
}
