import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/components/platform_alert_dialog.dart';
import 'package:visbooking_app/home/booking_entries/entry_list_item.dart';
import 'package:visbooking_app/home/booking_entries/entry_page.dart';
import 'package:visbooking_app/home/bookings/booking_list_tile.dart';
import 'package:visbooking_app/home/bookings/edit_booking_page.dart';
import 'package:visbooking_app/home/bookings/list_item_builder.dart';
import 'package:visbooking_app/home/models/entry.dart';
import 'package:visbooking_app/home/models/booking.dart';
import 'package:visbooking_app/screens/payment_screen.dart';
import 'package:visbooking_app/services/database.dart';

class BookingEntriesPage extends StatelessWidget {
  const BookingEntriesPage({@required this.database, @required this.booking});

  final Database database;
  final Booking booking;

  static Future<void> show(BuildContext context, Booking booking) async {
    final Database database = Provider.of<Database>(context);
    await Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: false,
        builder: (context) =>
            BookingEntriesPage(database: database, booking: booking),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
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
    return StreamBuilder<Booking>(
        stream: database.bookingStream(bookingId: booking.id),
        builder: (context, snapshot) {
          final booking = snapshot.data;
          final bookingName = booking?.name ?? '';

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 2.0,
              title: Text('Select Time Slot'),
              backgroundColor: Color(0xFF089083),
              // actions: <Widget>[
              //   IconButton(
              //     icon: Icon(
              //       Icons.mode_edit,
              //       color: Colors.white,
              //     ),
              //     onPressed: () => EditBookingPage.show(context,
              //         database: database, booking: booking),
              //   ),
              //   IconButton(
              //     icon: Icon(
              //       Icons.add,
              //       color: Colors.white,
              //     ),
              //     onPressed: () => EntryPage.show(
              //       context: context,
              //       database: database,
              //       booking: booking,
              //     ),
              //   ),
              // ],
            ),
            body: _buildContent(context, booking),
          );
        });
  }

  Widget _buildContent(BuildContext context, Booking booking) {
    return StreamBuilder<List<Entry>>(
      stream: database.entriesStream(booking: booking),
      builder: (context, snapshot) {
        return ListItemsBuilder<Entry>(
          snapshot: snapshot,
          itemBuilder: (context, entry) => Dismissible(
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
            // onDismissed: (direction) => _delete(context, booking),
            child: EntryListItem(
              entry: entry,
              booking: booking,
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PaymentScreen()));
              },
            ),
          ),
        );
      },
    );
  }
}
