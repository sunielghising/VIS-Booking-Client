import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/components/sign_in_button.dart';
import 'package:visbooking_app/components/social_sign_in_button.dart';
import 'package:visbooking_app/localization/localization_constants.dart';
import 'package:visbooking_app/classes/language.dart';
import 'package:visbooking_app/models/email_sign_in_change_model.dart';
import 'package:visbooking_app/models/sign_in_manager.dart';
import 'package:visbooking_app/screens/email_sign_in_form_bloc_based.dart';
import 'package:visbooking_app/screens/email_sign_in_form_change_notifier.dart';
import 'package:visbooking_app/screens/email_sign_in_page_stateful.dart';
import 'package:visbooking_app/services/auth.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({
    Key key,
    @required this.manager,
    @required this.isLoading,
  }) : super(key: key);
  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (context, manager, _) => LoginScreen(
              manager: manager,
              isLoading: isLoading.value,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await manager.signInAnonymously();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } catch (e) {
      print(e.toString());
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) {
          return EmailSignInPageStateful();
        },
      ),
    );
  }

  void _changeLanguage(Language language, BuildContext context) async {
    Locale _temp = await setLocale(language.languageCode);

    VisApp.setLocale(context, _temp);
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xFF089083),
        title: Text(getTranslated(context, 'login')),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DropdownButton(
              onChanged: (Language language) {
                _changeLanguage(language, context);
              },
              underline: SizedBox(),
              icon: Icon(
                Icons.language,
                color: Colors.white,
              ),
              items: Language.languageList()
                  .map<DropdownMenuItem<Language>>(
                    (lang) => DropdownMenuItem(
                      value: lang,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            lang.name,
                            style: TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                          Text(lang.flag),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              child: _buildHeader(),
              height: 50.0,
            ),
            Icon(
              Icons.pets,
              color: Color(0xFF089083),
              size: 100.0,
            ),
            Text(
              getTranslated(context, 'vis'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF089083),
              ),
            ),
            SizedBox(height: 48.0),
            SocialSignInButton(
              assetName: 'images/google-logo.png',
              text: getTranslated(context, 'login_google'),
              textColor: Colors.black,
              color: Colors.white,
              onPressed: isLoading ? null : () => _signInWithGoogle(context),
            ),
            SizedBox(height: 8.0),
            SocialSignInButton(
              assetName: 'images/facebook-logo.png',
              text: getTranslated(context, 'login_facebook'),
              textColor: Colors.white,
              color: Color(0xFF334D92),
              onPressed: isLoading ? null : () => _signInWithFacebook(context),
            ),
            SizedBox(height: 8.0),
            SignInButton(
              text: getTranslated(context, 'login_email'),
              textColor: Colors.white,
              color: Colors.teal[700],
              onPressed: isLoading ? null : () => _signInWithEmail(context),
            ),
            SizedBox(height: 8.0),
            Text(
              'or',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            SignInButton(
              text: getTranslated(context, 'login_anonymous'),
              textColor: Colors.black,
              color: Colors.lime[400],
              onPressed: () => _signInAnonymously(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
