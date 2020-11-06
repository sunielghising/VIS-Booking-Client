import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/components/avatar.dart';
import 'package:visbooking_app/components/platform_alert_dialog.dart';
import 'package:visbooking_app/home/booking_entries/booking_entries_page.dart';
import 'package:visbooking_app/home/bookings/edit_booking_page.dart';
import 'package:visbooking_app/home/bookings/booking_list_tile.dart';
import 'package:visbooking_app/home/bookings/list_item_builder.dart';
import 'package:visbooking_app/home/models/booking.dart';
import 'package:visbooking_app/screens/payment_screen.dart';
import 'package:visbooking_app/services/auth.dart';
import 'package:visbooking_app/services/database.dart';

class BookingsPage extends StatelessWidget {
  static const String id = 'dashboard_screen';

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
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

  Future<void> _delete(BuildContext context, Booking booking) async {
    try {
      final database = Provider.of<Database>(context);
      await database.deleteBooking(booking);
    } catch (e) {
      PlatformAlertDialog(
        title: 'Operation Failed',
        content: e.toString(),
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      drawer: Drawer(
        child: _drawerList(context, user),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF089083),
        title: Text('Select your interpreter'),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.add,
        //       color: Colors.white,
        //     ),
        //     onPressed: () => EditBookingPage.show(
        //       context,
        //       database: Provider.of<Database>(context),
        //     ),
        //   ),
        // ],
      ),
      body: _buildContents(context),
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
      color: Color(0xFF089083),
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

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<List<Booking>>(
      stream: database.bookingsStream(),
      builder: (context, snapshot) {
        return ListItemsBuilder<Booking>(
          snapshot: snapshot,
          itemBuilder: (context, booking) => Dismissible(
            key: Key('booking-${booking.id}'),
            background: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _delete(context, booking),
            child: BookingListTile(
              booking: booking,
              onTap: () => BookingEntriesPage.show(context, booking),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(User user) {
    return Avatar(
      radius: 50,
      photoUrl: user.photoUrl,
    );
  }
}
