import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/home/bookings/bookings_page.dart';
import 'package:visbooking_app/home/home_page.dart';
import 'package:visbooking_app/screens/login_screen.dart';
import 'package:visbooking_app/services/auth.dart';
import 'package:visbooking_app/services/database.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (user == null) {
            return LoginScreen.create(context);
          }
          return Provider<User>.value(
            value: user,
            child: Provider<Database>(
              create: (_) => FirestoreDatabase(
                uid: user.uid,
              ),
              child: HomePage(),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
