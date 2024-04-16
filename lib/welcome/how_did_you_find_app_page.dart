import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rememberme/welcome/welcome.dart';

class HowDidYouFindAppPage extends StatefulWidget {
  const HowDidYouFindAppPage({Key? key}) : super(key: key);

  @override
  _HowDidYouFindAppPageState createState() => _HowDidYouFindAppPageState();
}

class _HowDidYouFindAppPageState extends State<HowDidYouFindAppPage> {
  late String selectedOption = '';

  final double fontSize = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: Text(
          AppLocalizations.of(context)!.findTheApp,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20.0),
            RadioListTile<String>(
              title: Text(
                AppLocalizations.of(context)!.fromAFriend,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'From a friend',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(
                AppLocalizations.of(context)!.sawAnAd,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'Saw an ad',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(
                AppLocalizations.of(context)!.internetSearch,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'Internet search',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
              activeColor: Colors.pink,
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(
                AppLocalizations.of(context)!.other,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
              value: 'Other',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
              activeColor: Colors.pink,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            // Logique pour passer à la prochaine page ici
            if (selectedOption.isNotEmpty) {
              // Naviguer vers la prochaine page
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const WelcomePage();
              }));
            } else {
              // Afficher un message d'erreur si aucune option n'est sélectionnée
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.pleaseSelectOption),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[300],
          ),
          child: Text(
            AppLocalizations.of(context)!.next,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
