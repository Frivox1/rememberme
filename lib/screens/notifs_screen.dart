import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rememberme/models/reminder_model.dart';
import 'package:rememberme/models/birthday_model.dart';
import 'package:rememberme/services/hive_service.dart';
import 'package:timezone/timezone.dart' as tz;

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

  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
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
        ).showSnackBar(SnackBar(content: Text('Ce rappel existe déjà.')));
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
      ).showSnackBar(SnackBar(content: Text('Rappel ajouté avec succès!')));
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
    final now = DateTime.now();
    print('🕒 Maintenant : $now');
    print('🎂 Anniversaire de ${birthday.name} : ${birthday.birthdayDate}');

    // Trouver la prochaine occurrence de l'anniversaire
    final nextBirthday = getNextOccurrence(birthday.birthdayDate);

    // Calculer la date de notification
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

    // Convertir en TZDateTime juste avant de programmer la notification
    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    print(
      '✅ Programmation de notification pour ${birthday.name} le $scheduledDate, ${reminder.daysBefore} jours avant',
    );

    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      birthday.hashCode + reminder.hashCode,
      '🎉 Anniversaire de ${birthday.name}',
      'Dans ${reminder.daysBefore} jours',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des rappels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: _scheduleAllNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReminderForm(),
          const Divider(),
          Expanded(child: _buildRemindersList()),
        ],
      ),
    );
  }

  Widget _buildReminderForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jours avant l\'événement',
                suffixText: 'jours (0-30)',
              ),
              validator: (value) {
                final val = int.tryParse(value ?? '');
                if (val == null || val < 0 || val > 30) {
                  return 'Valeur entre 0 et 30';
                }
                return null;
              },
              onChanged: (value) => _daysBefore = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Heure de notification'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(context),
            ),
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text('Ajouter un rappel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    return ValueListenableBuilder(
      valueListenable: _remindersBox.listenable(),
      builder: (context, Box<Reminder> box, _) {
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final reminder = box.getAt(index)!;
            return ListTile(
              title: Text('${reminder.daysBefore} jours avant'),
              subtitle: Text('À ${reminder.time.format(context)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteReminder(index),
              ),
            );
          },
        );
      },
    );
  }
}
