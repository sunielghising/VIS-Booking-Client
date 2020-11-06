import 'package:flutter/cupertino.dart';

class Booking {
  Booking({@required this.id, @required this.name, @required this.ratePerHour});
  final String id;
  final String name;
  final int ratePerHour;

  factory Booking.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final int ratePerHour = data['ratePerHour'];
    return Booking(
      id: documentId,
      name: name,
      ratePerHour: ratePerHour,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ratePerHour': ratePerHour,
    };
  }
}
