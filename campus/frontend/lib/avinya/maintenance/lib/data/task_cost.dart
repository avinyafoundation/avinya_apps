class TaskCost {
  final int taskId;
  final String taskTitle;
  final double actualCost;
  final double estimatedCost;

  TaskCost({
    required this.taskId,
    required this.taskTitle,
    required this.actualCost,
    required this.estimatedCost,
  });

  factory TaskCost.fromJson(Map<String, dynamic> json) {
    return TaskCost(
      taskId: json['taskId'] as int,
      taskTitle: json['taskTitle'] as String,
      actualCost: (json['actualCost'] as num).toDouble(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'actualCost': actualCost,
        'estimatedCost': estimatedCost,
      };
}
