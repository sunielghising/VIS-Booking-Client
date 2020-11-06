import 'package:flutter/material.dart';
import 'package:visbooking_app/home/bookings/bookings_page.dart';

class BookingsFinish extends StatefulWidget {
  @override
  _BookingsFinishState createState() => _BookingsFinishState();
}

class _BookingsFinishState extends State<BookingsFinish> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Successful'),
        backgroundColor: Color(0xFF089083),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 10.0,
              ),
              Icon(
                Icons.check_circle_outline,
                size: 150.0,
                color: Color(0xFF089083),
              ),
              SizedBox(
                height: 40.0,
              ),
              Text(
                'Booking Successful',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Color(0xFF089083),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'Thank you for making',
                style: TextStyle(
                  fontSize: 32.0,
                  color: Color(0xFF089083),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'an appointment with us',
                style: TextStyle(fontSize: 32.0, color: Color(0xFF089083)),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50.0,
              ),
              RaisedButton(
                child: Text('Done'),
                color: Color(0xFF089083),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
