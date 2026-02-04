import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../tabs/main_dashboard_screen.dart';
import '../tabs/smart_monitor_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MainController(), permanent: true);

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true, // [필수] 이 옵션이 있어야 탭바가 내용 위에 둥둥 떠 있는 연출이 가능합니다.
      body: Obx(() {
        return IndexedStack(
          index: c.tabIndex.value,
          children: const [
            MainDashboardScreen(),
            SmartMonitorScreen(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return WeatherBottomNav(
          index: c.tabIndex.value,
          onChanged: c.setTab,
        );
      }),
    );
  }
}