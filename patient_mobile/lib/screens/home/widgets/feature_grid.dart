import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class FeatureGrid extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback onEmr;

  const FeatureGrid({
    Key? key,
    required this.onBookAppointment,
    required this.onEmr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.calendar_month, 'label': 'Đặt khám', 'onTap': onBookAppointment},
      {'icon': Icons.folder_shared, 'label': 'Hồ sơ', 'onTap': onEmr},
      {'icon': Icons.payment, 'label': 'Thanh toán', 'onTap': () {}},
      {'icon': Icons.history, 'label': 'Lịch sử', 'onTap': () {}},
      {'icon': Icons.menu_book, 'label': 'Cẩm nang', 'onTap': () {}},
      {'icon': Icons.support_agent, 'label': 'Hỗ trợ', 'onTap': () {}},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 1,
            child: InkWell(
              onTap: feature['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
