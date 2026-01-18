import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (Locale locale) {
        localeProvider.setLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: const Locale('en'),
            child: Row(
              children: [
                const Text('🇬🇧'),
                const SizedBox(width: 8),
                Text(l10n.english),
                if (localeProvider.locale.languageCode == 'en')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 16),
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: const Locale('ar'),
            child: Row(
              children: [
                const Text('🇸🇦'),
                const SizedBox(width: 8),
                Text(l10n.arabic),
                if (localeProvider.locale.languageCode == 'ar')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 16),
                  ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
