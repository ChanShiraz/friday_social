import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/event.dart';
import 'event_controller.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EventController>(tag: event.id)
        ? Get.find<EventController>(tag: event.id)
        : Get.put(
            EventController(initialEvent: event),
            tag: event.id,
          );

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(event.date);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Event Details',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
            fontSize: 12,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: event.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: event.accentColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.venue,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (event.address.isNotEmpty)
                          Text(
                            event.address,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        Text(
                          '${event.distanceKm} km away',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.endTime != null && event.endTime!.isNotEmpty
                        ? '${event.time} – ${event.endTime}'
                        : event.time,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (event.weatherNote != null && event.weatherNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wb_cloudy_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          event.weatherNote!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'About Event',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () {
                  final evt = controller.event.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Going: ${evt.attendeesCount}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.outlineVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              evt.capacity != null
                                  ? 'Capacity: ${evt.capacity}'
                                  : 'Open Capacity',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                            if (evt.isFull) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBA1A1A).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'FULL',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: const Color(0xFFBA1A1A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (controller.isAttending.value)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "YOU'RE GOING",
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Obx(() {
                final attending = controller.isAttending.value;
                final isSyncing = controller.isSubmittingRsvp.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSyncing ? null : controller.toggleAttend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: attending
                              ? AppColors.surfaceContainerHigh
                              : AppColors.primary,
                          foregroundColor: attending
                              ? AppColors.onSurface
                              : AppColors.onPrimary,
                          disabledBackgroundColor: attending
                              ? AppColors.surfaceContainerHigh
                              : AppColors.primary.withValues(alpha: 0.8),
                          disabledForegroundColor: attending
                              ? AppColors.onSurface
                              : AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: attending ? 0 : 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSyncing) ...[
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: attending
                                      ? AppColors.onSurface
                                      : AppColors.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ] else if (attending) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              attending ? "You're Going" : 'Join Event',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: attending
                                    ? AppColors.onSurface
                                    : AppColors.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (attending) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Tap above to release your reservation',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
