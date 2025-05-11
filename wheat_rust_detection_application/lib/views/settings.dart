import 'package:flutter/material.dart';
import 'package:wheat_rust_detection_application/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool popularPostsNotification = true;
  bool answerNotification = true;

  Locale? _selectedLocale;

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('am'),
    // Add more as needed
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _selectedLocale = Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            Text(
              AppLocalizations.of(context)!.general,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            DropdownButton<Locale>(
              value: _selectedLocale ?? supportedLocales.first,
              items: supportedLocales.map((locale) {
                final langName = locale.languageCode == 'en'
                    ? 'English'
                    : locale.languageCode == 'am'
                        ? 'አማርኛ'
                        : locale.languageCode;
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(langName),
                );
              }).toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  setState(() {
                    _selectedLocale = newLocale;
                  });
                  MyApp.setLocale(context, newLocale);
                }
              },
            ),
            const Divider(),

            // Notifications Section
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.notifications,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),
            _buildNotificationItem(
              title: AppLocalizations.of(context)!.popularPosts,
              subtitle: AppLocalizations.of(context)!.receivePushNotification,
              value: popularPostsNotification,
              onChanged: (val) {
                setState(() {
                  popularPostsNotification = val;
                });
              },
            ),
            const Divider(),
            _buildNotificationItem(
              title: AppLocalizations.of(context)!.answerToYourPost,
              subtitle: AppLocalizations.of(context)!.receivePushNotification,
              value: answerNotification,
              onChanged: (val) {
                setState(() {
                  answerNotification = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Transform.scale(
              scale: 0.8, // Adjust this value to change the size
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            )
          ],
        ),
      ],
    );
  }
}
