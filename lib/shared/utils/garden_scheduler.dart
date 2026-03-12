import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

final gardenSchedulerProvider = Provider<GardenScheduler>((ref) {
  return GardenScheduler(ref.read(notificationServiceProvider));
});

class GardenScheduler {
  GardenScheduler(this._notifications);
  final NotificationService _notifications;

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
    'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
    'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  // Call this on login and after any garden change
  Future<void> scheduleAll(String userId, String zone) async {
    await _notifications.cancelAll();

    final client = Supabase.instance.client;

    // Get all user's garden plants with calendar data
    final res = await client
        .from('garden_plants')
        .select('''
          id,
          custom_name,
          gardens!inner(user_id),
          plants(
            common_name,
            emoji,
            plant_calendar(zone, indoor_start, transplant, harvest)
          )
        ''')
        .eq('gardens.user_id', userId);

    if ((res as List).isEmpty) return;

    int notifId = 100; // start above 0 to avoid conflicts

    for (final row in res) {
      final plant    = row['plants'] as Map<String, dynamic>?;
      if (plant == null) continue;

      final name     = (row['custom_name'] as String?)
          ?? plant['common_name'] as String;
      final emoji    = plant['emoji'] as String? ?? '🌱';
      final calendar = (plant['plant_calendar'] as List?)
          ?.firstWhere(
            (c) => (c['zone'] as String?) == zone,
            orElse: () => null,
          );

      if (calendar == null) continue;

      final indoorStart = calendar['indoor_start'] as String?;
      final transplant  = calendar['transplant']   as String?;
      final harvest     = calendar['harvest']       as String?;

      // Schedule indoor start
      if (indoorStart != null && indoorStart != 'N/A') {
        final date = _parseDateString(indoorStart);
        if (date != null) {
          await _notifications.scheduleNotification(
            id: notifId++,
            title: '$emoji Time to start $name indoors!',
            body: 'Today is the day to sow your $name seeds indoors.',
            scheduledDate: date,
          );
        }
      }

      // Schedule transplant
      if (transplant != null && transplant != 'N/A') {
        final date = _parseDateString(transplant);
        if (date != null) {
          await _notifications.scheduleNotification(
            id: notifId++,
            title: '$emoji Time to transplant $name!',
            body: 'Your $name seedlings are ready to go outside.',
            scheduledDate: date,
          );
        }
      }

      // Schedule harvest start
      if (harvest != null && harvest != 'N/A') {
        final date = _parseDateString(harvest.split('–').first.trim());
        if (date != null) {
          await _notifications.scheduleNotification(
            id: notifId++,
            title: '$emoji $name harvest time!',
            body: 'Check your $name — it should be ready to harvest.',
            scheduledDate: date,
          );
        }
      }
    }

    // Weekly reminder — every Sunday at 8am
    await _scheduleWeeklyReminder(notifId);
  }

  Future<void> _scheduleWeeklyReminder(int id) async {
    // Find next Sunday
    final now  = DateTime.now();
    final days = (7 - now.weekday) % 7;
    final next = DateTime(now.year, now.month, now.day + (days == 0 ? 7 : days), 8, 0);

    await _notifications.scheduleNotification(
      id: id,
      title: '🌿 Weekly garden check',
      body: 'How are your plants doing this week?',
      scheduledDate: next,
    );
  }

  // Parse "Mar 15" or "Mar 15–Apr 1" → DateTime (current or next year)
  DateTime? _parseDateString(String s) {
    try {
      final parts = s.trim().toLowerCase().split(RegExp(r'[\s–-]+'));
      if (parts.length < 2) return null;

      final month = _months[parts[0].substring(0, 3)];
      final day   = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
      if (month == null || day == null) return null;

      final now  = DateTime.now();
      var   year = now.year;

      // If the date has already passed this year, schedule for next year
      final candidate = DateTime(year, month, day, 8, 0);
      if (candidate.isBefore(now)) year++;

      return DateTime(year, month, day, 8, 0);
    } catch (_) {
      return null;
    }
  }
}
