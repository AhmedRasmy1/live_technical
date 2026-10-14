import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads a Firestore date field. `null` when absent or still pending
/// (a server timestamp that has not been resolved yet).
DateTime? dateFromFirestore(Object? value) => switch (value) {
  Timestamp() => value.toDate(),
  DateTime() => value,
  _ => null,
};

/// Converts a [DateTime] to what Firestore stores.
Object? dateToFirestore(DateTime? date) =>
    date == null ? null : Timestamp.fromDate(date);
