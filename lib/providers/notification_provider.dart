import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/models/reminder_model.dart';
import 'package:rememberme/services/app_localizations.dart';

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationProvider({required this.flutterLocalNotificationsPlugin});

  // Fonction pour planifier les notifications pour les anniversaires et les rappels
  Future<void> _scheduleBirthdayNotification(
    Birthday birthday,
    Reminder reminder,
    BuildContext context,
  ) async {
    final nextBirthday = _getNextOccurrence(birthday.birthdayDate);
    final notificationDate = nextBirthday.subtract(
      Duration(days: reminder.daysBefore),
    );
    final notificationTime = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    print(
      '🔔 ${birthday.name} → $scheduledDate (${reminder.daysBefore} jours avant)',
    );

    final title = t(context, 'notif title').replaceAll('{name}', birthday.name);
    String body;

    if (reminder.daysBefore == 0) {
      body = t(context, 'notif body').replaceAll('{name}', birthday.name);
    } else if (reminder.daysBefore == 1) {
      body = t(
        context,
        'notif body tomorrow',
      ).replaceAll('{name}', birthday.name);
    } else {
      body = t(context, 'notif body in x days')
          .replaceAll('{name}', birthday.name)
          .replaceAll('{days}', reminder.daysBefore.toString());
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      birthday.hashCode + reminder.hashCode,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'birthday_reminders',
          'Rappels anniversaires',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: 'birthday_${birthday.id}',
    );
  }

  // Calculer la prochaine occurrence de l'anniversaire
  DateTime _getNextOccurrence(DateTime date) {
    final now = DateTime.now();
    final nextOccurrence = DateTime(now.year, date.month, date.day);
    if (nextOccurrence.isBefore(now)) {
      return DateTime(now.year + 1, date.month, date.day);
    }
    return nextOccurrence;
  }

  // Fonction pour planifier toutes les notifications pour un anniversaire
  Future<void> scheduleAllBirthdayNotifications(
    List<Birthday> birthdays,
    List<Reminder> reminders,
    BuildContext context,
  ) async {
    for (final birthday in birthdays) {
      for (final reminder in reminders) {
        await _scheduleBirthdayNotification(birthday, reminder, context);
      }
    }
    notifyListeners();
  }
}
