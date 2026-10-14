class FirestoreConstants {
  static const String employees = 'employees';
  static const String boards = 'boards';
  static const String createdAt = 'createdAt';
  static const String boardName = 'boardName';

  // Database Builder
  static const String databases = 'databases';

  /// Sub-collection of a database: one document per employee that may open it.
  static const String access = 'access';
  static const String creationDate = 'creationDate';
  static const String lastEditDate = 'lastEditDate';
  static const String grantedAt = 'grantedAt';
  static const String employeeId = 'employeeId';
  static const String permissions = 'permissions';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';

  /// A Firestore batch holds at most 500 writes; one is the database itself.
  static const int maxBatchWrites = 500;
  static const int maxDatabaseMembers = maxBatchWrites - 1;

  /// Firestore calls never fail while offline, they wait. Give up after this.
  static const Duration timeout = Duration(seconds: 15);
}
