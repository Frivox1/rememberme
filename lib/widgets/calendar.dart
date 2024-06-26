import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:hive/hive.dart';
import 'package:rememberme/models/language_model.dart';

class MinimalCalendar extends StatelessWidget {
  const MinimalCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // Récupérez la langue stockée dans la boîte de données 'language'
    final languageBox = Hive.box<LanguageModel>('language');
    final languageModel =
        languageBox.get('locale', defaultValue: LanguageModel(locale: 'en'));
    final selectedLanguage = languageModel!.locale;

    return CalendarCarousel(
      locale: selectedLanguage,
      todayBorderColor:
          Colors.transparent, // Couleur de bordure pour le jour actuel
      todayButtonColor: Colors.transparent, // Couleur du bouton "Today"
      selectedDayButtonColor: Colors.pink[200]!, // Couleur du jour sélectionné
      onDayPressed: (DateTime date, List events) {
        // Gérer l'action lorsqu'un jour est sélectionné
        print(date);
      },
      thisMonthDayBorderColor: Colors
          .transparent, // Couleur de bordure pour les jours du mois en cours
      headerMargin:
          const EdgeInsets.only(bottom: 8.0), // Marge inférieure pour l'en-tête
      headerTextStyle: const TextStyle(
          fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold),
      iconColor: Colors.black, // Couleur des icônes
      todayTextStyle:
          TextStyle(color: Colors.black), // Style du texte du jour actuel
      selectedDayTextStyle:
          TextStyle(color: Colors.white), // Style du texte du jour sélectionné
      daysTextStyle: TextStyle(color: Colors.black), // Style du texte des jours
      weekendTextStyle:
          TextStyle(color: Colors.black), // Style du texte pour les week-ends
      markedDatesMap: EventList<EventInterface>(
          events: {DateTime(2024, 4, 12): []}), // Dates marquées
      markedDateCustomTextStyle:
          TextStyle(color: Colors.pink), // Style du texte des dates marquées
      weekdayTextStyle: TextStyle(
          color: Colors.pink), // Style du texte pour les jours de la semaine
      weekDayFormat: WeekdayFormat.short, // Format des jours de la semaine
      height: 420.0, // Hauteur du calendrier
      width: MediaQuery.of(context).size.width, // Largeur du calendrier
      selectedDateTime: today, // Date sélectionnée par défaut
      firstDayOfWeek:
          1, // Premier jour de la semaine (0 pour dimanche, 1 pour lundi, etc.)
      showHeader: true, // Afficher l'en-tête du calendrier
      customGridViewPhysics:
          const NeverScrollableScrollPhysics(), // Physique de défilement pour le calendrier
    );
  }
}
