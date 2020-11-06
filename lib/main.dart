import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:visbooking_app/localization/demo_localization.dart';
import 'package:visbooking_app/screens/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:visbooking_app/localization/localization_constants.dart';
import 'package:visbooking_app/services/auth.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VisApp());
}

class VisApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    _VisAppState state = context.findAncestorStateOfType<_VisAppState>();
    state.setLocale(locale);
  }

  @override
  _VisAppState createState() => _VisAppState();
}

class _VisAppState extends State<VisApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Provider<AuthBase>(
        create: (context) => Auth(),
        child: MaterialApp(
          locale: _locale,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('zh', 'CN'),
          ],
          localizationsDelegates: [
            DemoLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode &&
                  locale.countryCode == deviceLocale.countryCode) {
                return deviceLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          home: LandingPage(),
        ),
      );
    }
  }
}
