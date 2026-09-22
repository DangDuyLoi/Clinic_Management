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
        appBar: AppBar(
          title: const Text('Hồ Sơ Bệnh Án'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: [
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
