import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:provider/provider.dart';
import 'package:rememberme/providers/langue_provider.dart';

class MinimalCalendar extends StatelessWidget {
  const MinimalCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // hop récup dans le provider de la langue
    final selectedLanguage =
        Provider.of<LanguageProvider>(context).locale.languageCode;

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
          TextStyle(color: Colors.red), // Style du texte pour les week-ends
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
