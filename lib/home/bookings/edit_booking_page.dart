import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visbooking_app/components/platform_alert_dialog.dart';
import 'package:visbooking_app/constants.dart';
import 'package:visbooking_app/home/models/booking.dart';
import 'package:visbooking_app/services/database.dart';

class EditBookingPage extends StatefulWidget {
  const EditBookingPage({Key key, this.database, this.booking})
      : super(key: key);
  final Database database;
  final Booking booking;

  static Future<void> show(
    BuildContext context, {
    Database database,
    Booking booking,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => EditBookingPage(
          database: database,
          booking: booking,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _name = widget.booking.name;
      _ratePerHour = widget.booking.ratePerHour;
    }
  }

  final _formKey = GlobalKey<FormState>();

  String _name;
  int _ratePerHour;

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final bookings = await widget.database.bookingsStream().first;
        final allNames = bookings.map((booking) => booking.name).toList();
        if (widget.booking != null) {
          allNames.remove(widget.booking.name);
        }
        if (allNames.contains(_name)) {
          PlatformAlertDialog(
            content: 'Please choose a different interpreter name',
            defaultActionText: 'OK',
            title: 'Name already used',
          ).show(context);
        } else {
          final id = widget.booking?.id ?? documentIdFromCurrentDate();
          final booking = Booking(
            id: id,
            name: _name,
            ratePerHour: _ratePerHour,
          );
          await widget.database.setBooking(booking);
          Navigator.of(context).pop();
        }
      } catch (e) {
        PlatformAlertDialog(
          title: 'Operation Failed',
          content: e.toString(),
          defaultActionText: 'OK',
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'New Booking' : 'Edit Booking'),
        backgroundColor: Color(0xFF089083),
        actions: [
          FlatButton(
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _submit,
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        onSaved: (value) => _name = value,
        decoration: kTextFieldDecoration.copyWith(
          labelText: 'Interpreter Name',
          labelStyle: TextStyle(
            color: Color(0xFF089083),
          ),
          prefixIcon: Icon(
            Icons.person_add,
            color: Color(0xFF089083),
          ),
        ),
        initialValue: _name,
        validator: (value) => value.isNotEmpty ? null : 'Name can\'t be empty',
      ),
      SizedBox(height: 8.0),
      TextFormField(
        initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        onSaved: (value) => _ratePerHour = int.tryParse(value) ?? 0,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        decoration: kTextFieldDecoration.copyWith(
          labelText: 'Rate per hour',
          labelStyle: TextStyle(
            color: Color(0xFF089083),
          ),
          prefixIcon: Icon(
            Icons.attach_money,
            color: Color(0xFF089083),
          ),
        ),
      ),
    ];
  }
}
