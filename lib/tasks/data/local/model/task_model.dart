class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime? startDateTime;
  final String priority;
  final bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.startDateTime,
    required this.priority,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDateTime': startDateTime?.toIso8601String(),
      'priority': priority,
      'completed': completed ? 1 : 0,
    };
  }

  static TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDateTime: json['startDateTime'] != null
          ? DateTime.parse(json['startDateTime'])
          : null,
      priority: json['priority'],
      completed: json['completed'] == 1,
    );
  }
}
