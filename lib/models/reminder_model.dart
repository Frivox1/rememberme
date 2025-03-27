import 'package:hive_ce/hive.dart';
import 'package:flutter/material.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class Reminder {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  @HiveField(2)
  final int daysBefore;

  Reminder({
    required this.hour,
    required this.minute,
    required this.daysBefore,
  });

  factory Reminder.fromTimeOfDay({
    required TimeOfDay time,
    required int daysBefore,
  }) {
    return Reminder(
      hour: time.hour,
      minute: time.minute,
      daysBefore: daysBefore,
    );
  }

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);
}
