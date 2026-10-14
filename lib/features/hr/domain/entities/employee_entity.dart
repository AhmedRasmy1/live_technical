class EmployeeEntity {
  final String? id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String department;
  final String jobTitle;
  final String? imageUrl;

  const EmployeeEntity({
    this.id,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    required this.department,
    required this.jobTitle,
    this.imageUrl,
  });

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part.trim().isNotEmpty).join(' ');
}
