class FirestoreConstants {
  static const String employees = 'employees';
  static const String boards = 'boards';
  static const String createdAt = 'createdAt';
  static const String boardName = 'boardName';

  /// Firestore calls never fail while offline, they wait. Give up after this.
  static const Duration timeout = Duration(seconds: 15);
}
