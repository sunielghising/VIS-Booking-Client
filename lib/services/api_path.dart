class APIPath {
  static String booking(String uid, String bookingId) =>
      'users/$uid/bookings/$bookingId';

  static String bookings(String uid) => 'users/$uid/bookings';

  static String entry(String uid, String entryId) =>
      'users/$uid/entries/$entryId';

  static String entries(String uid) => 'users/$uid/entries';
}
