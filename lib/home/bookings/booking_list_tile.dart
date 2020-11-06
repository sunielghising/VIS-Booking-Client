import 'package:flutter/material.dart';
import 'package:visbooking_app/home/models/booking.dart';

class BookingListTile extends StatelessWidget {
  const BookingListTile({Key key, @required this.booking, this.onTap})
      : super(key: key);
  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(booking.name),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
