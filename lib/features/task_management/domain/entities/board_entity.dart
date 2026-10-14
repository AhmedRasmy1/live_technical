class BoardEntity {
  final String? id;
  final String boardName;
  final String boardNameAr;
  final String description;
  final String descriptionAr;
  final List<String> departments;
  final bool isMessagingEnabled;
  final List<String> assignedEmployeeIds;

  const BoardEntity({
    this.id,
    required this.boardName,
    this.boardNameAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.departments = const [],
    this.isMessagingEnabled = false,
    this.assignedEmployeeIds = const [],
  });
}
