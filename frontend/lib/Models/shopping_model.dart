class ShoppingItem {
  String id;
  String name;
  String assignedTo;
  String notes;
  String dueTime;
  bool isDone;
  List<TaskItem> tasks;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.notes,
    required this.dueTime,
    this.isDone = false,
    this.tasks = const [],
  });
}

class TaskItem {
  String id;
  String title;
  String quanity;
  String unitName;
  bool isDone;
  TaskItem({
    required this.id,
    required this.title,
    required this.quanity,
    required this.unitName,
    required this.isDone,
  });
}
