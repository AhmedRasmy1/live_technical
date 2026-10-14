/// Lifecycle / visibility of a database. The dashboard tabs filter on it.
enum DatabaseStatus {
  open('Open'),
  restricted('Restricted'),
  personal('Personal'),
  draft('Draft'),
  deleted('Deleted');

  const DatabaseStatus(this.label);

  final String label;

  static DatabaseStatus? fromName(String? name) {
    for (final status in values) {
      if (status.name == name) return status;
    }
    return null;
  }
}

/// Who may open the database ("Access Management" dropdown).
enum AccessType {
  open('Open Access'),
  restricted('Restricted Access'),
  personal('Personal Access');

  const AccessType(this.label);

  final String label;

  /// Status of a database that is created (not a draft) with this access.
  DatabaseStatus get status => switch (this) {
    AccessType.open => DatabaseStatus.open,
    AccessType.restricted => DatabaseStatus.restricted,
    AccessType.personal => DatabaseStatus.personal,
  };

  static AccessType? fromName(String? name) {
    for (final type in values) {
      if (type.name == name) return type;
    }
    return null;
  }
}

/// What the granted employees may do ("Permissions" dropdown).
enum DatabasePermission {
  fullAccess('Full Access'),
  edit('Edit'),
  export('Export'),
  view('View');

  const DatabasePermission(this.label);

  final String label;

  static DatabasePermission? fromName(String? name) {
    for (final permission in values) {
      if (permission.name == name) return permission;
    }
    return null;
  }
}
