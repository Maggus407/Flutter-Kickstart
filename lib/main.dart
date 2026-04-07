import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/services/supabase/supabase_config.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lade Umgebungsvariablen
  await dotenv.load(fileName: ".env");

  // Supabase initialisieren
  await initializeSupabase();

  // Sentry initialisieren
  await SentryFlutter.init(
    (options) {
      // Sentry DSN aus der .env-Datei laden
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.tracesSampleRate = 1.0; // Sample Rate für Performance Monitoring
    },
    // Eure App in Sentry und ProviderScope wrappen!
    appRunner: () => runApp(
      const ProviderScope(
        // <- Das ist neu für Riverpod!
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Die Übersetzungs-Einrichtung (i18n):
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'), // Deutsch (als Standard)
        Locale('en'), // Englisch
      ],
      // Das dynamische Title wird oft so gesetzt:
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Statt einem normalen StatelessWidget nutzen wir hier das ConsumerWidget von Riverpod
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lass uns die Übersetzungen laden
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.helloWorld,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Hier erscheinen von Nutzern erstellte Events',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Simulierter Fehler für Sentry:
                throw Exception(l10n.triggerErrorButton);
              },
              child: Text(l10n.triggerErrorButton),
            ),
          ),
        ],
      ),
    );
  }
}
