import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rememberme/models/reminder_model.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/services/hive_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:rememberme/services/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final HiveService hiveService;

  const NotificationScreen({
    required this.flutterLocalNotificationsPlugin,
    required this.hiveService,
    Key? key,
  }) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _daysBefore = 0;
  late Box<Reminder> _remindersBox;

  @override
  void initState() {
    super.initState();
    _initHive();
    _requestPermissions();
  }

  Future<void> _initHive() async {
    _remindersBox = HiveService.remindersBox;
  }

  Future<void> _requestPermissions() async {
    await widget.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  bool _reminderExists(Reminder newReminder) {
    return _remindersBox.values.any(
      (reminder) =>
          reminder.daysBefore == newReminder.daysBefore &&
          reminder.time.hour == newReminder.time.hour &&
          reminder.time.minute == newReminder.time.minute,
    );
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final newReminder = Reminder.fromTimeOfDay(
        time: _selectedTime,
        daysBefore: _daysBefore,
      );

      if (_reminderExists(newReminder)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t(context, 'already_exists'))));
        return;
      }

      await _remindersBox.add(newReminder);
      await _scheduleAllNotifications();

      setState(() {
        _daysBefore = 0;
        _selectedTime = TimeOfDay.now();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t(context, 'success_added'))));
    }
  }

  Future<void> _scheduleAllNotifications() async {
    await widget.flutterLocalNotificationsPlugin.cancelAll();

    final birthdays = HiveService.getAllBirthdays();
    final reminders = HiveService.getReminders();

    for (final birthday in birthdays) {
      for (final reminder in reminders) {
        await _scheduleBirthdayNotification(birthday, reminder);
      }
    }
  }

  DateTime getNextOccurrence(DateTime date) {
    final now = DateTime.now();
    final nextOccurrence = DateTime(now.year, date.month, date.day);
    if (nextOccurrence.isBefore(now)) {
      return DateTime(now.year + 1, date.month, date.day);
    }
    return nextOccurrence;
  }

  Future<void> _scheduleBirthdayNotification(
    Birthday birthday,
    Reminder reminder,
  ) async {
    final nextBirthday = getNextOccurrence(birthday.birthdayDate);
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

    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
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

  Future<void> _deleteReminder(int index) async {
    await _remindersBox.deleteAt(index);
    await _scheduleAllNotifications();
  }

  void _openReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(t(context, 'add_reminder')),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t(context, 'days_before'),
                        suffixText: t(context, 'days_hint'),
                      ),
                      validator: (value) {
                        final val = int.tryParse(value ?? '');
                        if (val == null || val < 0 || val > 30) {
                          return t(context, 'days_hint');
                        }
                        return null;
                      },
                      onChanged:
                          (value) => _daysBefore = int.tryParse(value) ?? 0,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(t(context, 'time_label')),
                      subtitle: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (pickedTime != null) {
                          setState(() => _selectedTime = pickedTime);
                          setStateDialog(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t(context, 'cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    await _saveReminder();
                    Navigator.of(context).pop();
                  },
                  child: Text(t(context, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, 'reminder management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add, size: 26),
            onPressed: _openReminderDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(child: _buildRemindersList(context)),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: _remindersBox.listenable(),
      builder: (context, Box<Reminder> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Text(
              t(context, 'no_reminders'),
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        final sortedReminders =
            box.values.toList()
              ..sort((a, b) => a.daysBefore.compareTo(b.daysBefore));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = sortedReminders[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.daysBefore == 0
                            ? t(context, 'the same_day')
                            : reminder.daysBefore == 1
                            ? t(context, 'the day_before')
                            : t(context, 'multiple_days_before').replaceAll(
                              '{days}',
                              reminder.daysBefore.toString(),
                            ),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${t(context, 'at_time')} ${reminder.time.format(context)}",
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _deleteReminder(index),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
