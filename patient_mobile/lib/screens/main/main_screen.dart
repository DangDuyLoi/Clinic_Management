import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_screen.dart';
import '../home/notification_screen.dart';
import '../profile/user_profile_screen.dart';
import '../home/controllers/notification_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // Inject NotificationController here to ensure it's loaded early
  final NotificationController _notificationController = Get.put(NotificationController());

  final List<Widget> _pages = [
    const HomeScreen(),
    const NotificationScreen(),
    const Center(child: Text('Chức năng')), // Placeholder
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Obx(() {
        final unreadCount = _notificationController.unreadCount;
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF0056D2),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: unreadCount > 0 
                  ? Badge(label: Text(unreadCount.toString()), child: const Icon(Icons.notifications_outlined))
                  : const Icon(Icons.notifications_outlined),
              activeIcon: unreadCount > 0
                  ? Badge(label: Text(unreadCount.toString()), child: const Icon(Icons.notifications))
                  : const Icon(Icons.notifications),
              label: 'Thông báo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
              label: 'Chức năng',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        );
      }),
    );
  }
}
