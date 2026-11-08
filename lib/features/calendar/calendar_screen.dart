import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'calendar_controller.dart';
import 'widgets/atmosphere_header.dart';
import 'widgets/month_control_bar.dart';
import 'widgets/radius_control_bar.dart';
import 'widgets/month_calendar_grid.dart';
import 'widgets/agenda_summary_card.dart';
import 'widgets/location_service_disabled_banner.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AtmosphereHeader(controller: controller),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.secondary,
                backgroundColor: AppColors.surfaceContainerLowest,
                onRefresh: () async {
                  await controller.loadData(forceRefresh: true);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      LocationServiceDisabledBanner(controller: controller),
                      MonthControlBar(controller: controller),
                      RadiusControlBar(controller: controller),
                      MonthCalendarGrid(controller: controller),
                      AgendaSummaryCard(controller: controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
