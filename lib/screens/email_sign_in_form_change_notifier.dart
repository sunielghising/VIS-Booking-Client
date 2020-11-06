import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/classes/language.dart';
import 'package:visbooking_app/components/form_submit_button.dart';
import 'package:visbooking_app/components/platform_alert_dialog.dart';
import 'package:visbooking_app/localization/localization_constants.dart';
import 'package:visbooking_app/models/email_sign_in_change_model.dart';
import 'package:visbooking_app/models/email_sign_in_model.dart';
import 'package:visbooking_app/services/auth.dart';
import '../constants.dart';
import '../main.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  EmailSignInFormChangeNotifier({@required this.model});
  final EmailSignInChangeModel model;

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (context) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (context, model, _) => EmailSignInFormChangeNotifier(
          model: model,
        ),
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  void _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);

    VisApp.setLocale(context, _temp);
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  EmailSignInChangeModel get model => widget.model;

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  Future<void> _submit() async {
    try {
      await model.submit();
      Navigator.pop(context);
    } catch (e) {
      PlatformAlertDialog(
        title: 'Sign in failed',
        content: e.toString(),
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
    final primaryText = model.formType == EmailSignInFormType.signIn
        ? '${getTranslated(context, 'signIn')}'
        : '${getTranslated(context, 'create')}';
    final secondaryText = model.formType == EmailSignInFormType.signIn
        ? '${getTranslated(context, 'register')}'
        : '${getTranslated(context, 'already')}';
    final tertiaryText = model.formType == EmailSignInFormType.signIn
        ? '${getTranslated(context, 'login')}'
        : '${getTranslated(context, 'titleRegister')}';
    bool submitEnabled = model.emailValidator.isValid(model.email) &&
        model.passwordValidator.isValid(model.password) &&
        !model.isLoading;
    return [
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
        onPressed: !model.isLoading ? _toggleFormType : null,
      ),
    ];
  }

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
                children: _buildChildren(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildPasswordTextField(BuildContext context) {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: kTextFieldDecoration.copyWith(
        labelText: getTranslated(context, 'password'),
        labelStyle: TextStyle(
          color: Color(0xFF089083),
        ),
        errorText: model.passwordErrorText,
        prefixIcon: Icon(
          Icons.lock,
          color: Color(0xFF089083),
        ),
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.done,
      obscureText: true,
      onEditingComplete: _submit,
      onChanged: model.updatePassword,
    );
  }

  TextField _buildEmailTextField(BuildContext context) {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: kTextFieldDecoration.copyWith(
        labelText: getTranslated(context, 'email'),
        labelStyle: TextStyle(
          color: Color(0xFF089083),
        ),
        errorText: model.emailErrorText,
        prefixIcon: Icon(
          Icons.email,
          color: Color(0xFF089083),
        ),
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.next,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      onEditingComplete: () => _emailEditingComplete(),
      onChanged: model.updateEmail,
    );
  }
}
