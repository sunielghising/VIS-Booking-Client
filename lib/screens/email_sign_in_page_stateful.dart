import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/classes/language.dart';
import 'package:visbooking_app/components/form_submit_button.dart';
import 'package:visbooking_app/components/platform_alert_dialog.dart';
import 'package:visbooking_app/localization/localization_constants.dart';
import 'package:visbooking_app/models/validators.dart';
import 'package:visbooking_app/services/auth.dart';

import '../constants.dart';
import '../main.dart';

enum EmailSignInFormType {
  signIn,
  register,
}

class EmailSignInPageStateful extends StatefulWidget
    with EmailAndPasswordValidators {
  @override
  _EmailSignInPageStatefulState createState() =>
      _EmailSignInPageStatefulState();
}

class _EmailSignInPageStatefulState extends State<EmailSignInPageStateful> {
  void _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);

    VisApp.setLocale(context, _temp);
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  bool _submitted = false;
  bool _isLoading = false;

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    try {
      final auth = Provider.of<AuthBase>(context);
      if (_formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.createUserWithEmailAndPassword(_email, _password);
      }
      Navigator.pop(context);
    } catch (e) {
      PlatformAlertDialog(
        title: 'Sign in failed',
        content: e.toString(),
        defaultActionText: 'OK',
      ).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFormType() {
    setState(() {
      _submitted = false;
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final primaryText = _formType == EmailSignInFormType.signIn
        ? '${getTranslated(context, 'signIn')}'
        : '${getTranslated(context, 'create')}';
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? '${getTranslated(context, 'register')}'
        : '${getTranslated(context, 'already')}';
    final tertiaryText = _formType == EmailSignInFormType.signIn
        ? '${getTranslated(context, 'login')}'
        : '${getTranslated(context, 'titleRegister')}';
    bool submitEnabled = widget.emailValidator.isValid(_email) &&
        widget.passwordValidator.isValid(_password) &&
        !_isLoading;
    return Scaffold(
      key: _key,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xFF089083),
        title: Text(tertiaryText),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DropdownButton(
              onChanged: (Language language) {
                _changeLanguage(language);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEmailTextField(context),
                  SizedBox(height: 8.0),
                  _buildPasswordTextField(context),
                  SizedBox(height: 20.0),
                  FormSubmitButton(
                    text: primaryText,
                    onPressed: submitEnabled ? _submit : null,
                  ),
                  SizedBox(height: 8.0),
                  FlatButton(
                    child: Text(
                      secondaryText,
                      style: TextStyle(
                        color: Color(0xFF089083),
                      ),
                    ),
                    onPressed: !_isLoading ? _toggleFormType : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildPasswordTextField(BuildContext context) {
    bool showErrorText =
        _submitted && !widget.passwordValidator.isValid(_password);
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: kTextFieldDecoration.copyWith(
        labelText: getTranslated(context, 'password'),
        labelStyle: TextStyle(
          color: Color(0xFF089083),
        ),
        errorText: showErrorText ? widget.invalidPasswordErrorText : null,
        prefixIcon: Icon(
          Icons.lock,
          color: Color(0xFF089083),
        ),
        enabled: _isLoading == false,
      ),
      textInputAction: TextInputAction.done,
      obscureText: true,
      onEditingComplete: _submit,
      onChanged: (password) => _updateState(),
    );
  }

  TextField _buildEmailTextField(BuildContext context) {
    bool showErrorText = _submitted && !widget.emailValidator.isValid(_email);
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: kTextFieldDecoration.copyWith(
        labelText: getTranslated(context, 'email'),
        labelStyle: TextStyle(
          color: Color(0xFF089083),
        ),
        errorText: showErrorText ? widget.invalidEmailErrorText : null,
        prefixIcon: Icon(
          Icons.email,
          color: Color(0xFF089083),
        ),
        enabled: _isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      onEditingComplete: _emailEditingComplete,
      onChanged: (email) => _updateState(),
    );
  }

  void _updateState() {
    setState(() {});
  }
}
