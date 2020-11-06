import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/components/avatar.dart';
import 'package:visbooking_app/components/platform_alert_dialog.dart';
import 'package:visbooking_app/constants.dart';
import 'package:visbooking_app/screens/payment_screen.dart';
import 'package:visbooking_app/services/auth.dart';
import 'package:visbooking_app/src/pages/call.dart';
import 'package:visbooking_app/src/pages/index.dart';

class MeetingScreen extends StatefulWidget {
  static const String id = 'meeting_screen';

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    ).show(context);

    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      drawer: Drawer(
        child: _drawerList(context, user),
      ),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.teal[500],
        title: Text('Meetings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _channelController,
                    decoration: kTextFieldDecoration.copyWith(
                      errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      labelText: 'Channel name',
                      labelStyle: TextStyle(
                        color: Colors.teal[500],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  RaisedButton(
                    onPressed: onJoin,
                    child: Text('Join'),
                    color: Colors.teal[500],
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  Container _drawerList(BuildContext context, User user) {
    TextStyle _textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24.0,
    );
    return Container(
      padding: EdgeInsets.only(top: 50.0),
      width: MediaQuery.of(context).size.width / 1.5,
      color: Colors.teal[700],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.symmetric(horizontal: 60.0),
            child: PreferredSize(
              preferredSize: Size.fromHeight(130),
              child: _buildUserInfo(user),
            ),
          ),
          if (user.displayName != null)
            ListTile(
              title: Text(
                user.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 30.0,
            ),
            title: Text(
              'About Us',
              style: _textStyle,
            ),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30.0,
            ),
            title: Text(
              'Edit Profile',
              style: _textStyle,
            ),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 30.0,
            ),
            title: Text(
              'Sign Out',
              style: _textStyle,
            ),
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Avatar(
      radius: 50,
      photoUrl: user.photoUrl,
    );
  }
}
