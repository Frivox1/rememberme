import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MinimalCalendar extends StatelessWidget {
  final Map<DateTime, List<dynamic>> events;

  const MinimalCalendar({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfYear = DateTime(today.year, 1, 1);
    final endOfYear = DateTime(today.year, 12, 31);

    return TableCalendar(
      focusedDay: today,
      firstDay: startOfYear,
      lastDay: endOfYear,
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) => events[day] ?? [],
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final List<dynamic> birthdays = events;
          if (birthdays.isNotEmpty) {
            // Vérifie si la liste d'anniversaires n'est pas vide
            return Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: const BoxDecoration(
                    color: Colors
                        .red, // Couleur de marqueur pour les anniversaires
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            );
          }
          return null;
        },
      ),
    );
  }
}
