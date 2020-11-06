import 'dart:async';

import 'package:meta/meta.dart';
import 'package:visbooking_app/home/models/entry.dart';
import 'package:visbooking_app/home/models/booking.dart';
import 'package:visbooking_app/services/api_path.dart';
import 'package:visbooking_app/services/firestore_service.dart';

abstract class Database {
  Future<void> setBooking(Booking booking);
  Future<void> deleteBooking(Booking booking);
  Stream<List<Booking>> bookingsStream();

  Stream<Booking> bookingStream({@required String bookingId});

  Future<void> setEntry(Entry entry);
  Future<void> deleteEntry(Entry entry);
  Stream<List<Entry>> entriesStream({Booking booking});
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _service = FirestoreService.instance;

  @override
  Future<void> setBooking(Booking booking) async => await _service.setData(
        path: APIPath.booking(uid, booking.id),
        data: booking.toMap(),
      );

  @override
  Future<void> deleteBooking(Booking booking) async {
    // delete where entry.bookingId == booking.bookingId
    final allEntries = await entriesStream(booking: booking).first;
    for (Entry entry in allEntries) {
      if (entry.bookingId == booking.id) {
        await deleteEntry(entry);
      }
    }
    // delete booking
    await _service.deleteData(path: APIPath.booking(uid, booking.id));
  }

  @override
  Stream<Booking> bookingStream({@required String bookingId}) =>
      _service.documentStream(
        path: APIPath.booking(uid, bookingId),
        builder: (data, documentId) => Booking.fromMap(data, documentId),
      );

  @override
  Stream<List<Booking>> bookingsStream() => _service.collectionStream(
        path: APIPath.bookings(uid),
        builder: (data, documentId) => Booking.fromMap(data, documentId),
      );

  @override
  Future<void> setEntry(Entry entry) async => await _service.setData(
        path: APIPath.entry(uid, entry.id),
        data: entry.toMap(),
      );

  @override
  Future<void> deleteEntry(Entry entry) async =>
      await _service.deleteData(path: APIPath.entry(uid, entry.id));

  @override
  Stream<List<Entry>> entriesStream({Booking booking}) =>
      _service.collectionStream<Entry>(
        path: APIPath.entries(uid),
        queryBuilder: booking != null
            ? (query) => query.where('jobId', isEqualTo: booking.id)
            : null,
        builder: (data, documentID) => Entry.fromMap(data, documentID),
        sort: (lhs, rhs) => rhs.start.compareTo(lhs.start),
      );
}
