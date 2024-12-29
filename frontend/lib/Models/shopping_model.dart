class ShoppingItem {
  String id;
  String name;
  String assignedTo;
  String notes;
  String dueTime;
  String nameAssignedTo;
  bool isDone;
  List<TaskItem> tasks;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.notes,
    required this.dueTime,
    required this.nameAssignedTo,
    this.isDone = false,
    this.tasks = const [],
  });
}

class TaskItem {
  String id;
  String foodName;
  String title;
  String quanity;
  String unitName;
  bool isDone;
  TaskItem({
    required this.id,
    required this.foodName,
    required this.title,
    required this.quanity,
    required this.unitName,
    required this.isDone,
  });
}
