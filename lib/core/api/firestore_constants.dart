class FirestoreConstants {
  static const String employees = 'employees';
  static const String createdAt = 'createdAt';

  /// Firestore calls never fail while offline, they wait. Give up after this.
  static const Duration timeout = Duration(seconds: 15);
}
