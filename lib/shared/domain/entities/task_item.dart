import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.goalId,
    this.isRecurring = false,
    this.recurrenceRule,
    this.aiSuggestion,
    this.completedAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final String? goalId;
  final bool isRecurring;
  final String? recurrenceRule;
  final String? aiSuggestion;
  final DateTime? completedAt;
  final DateTime? createdAt;

  bool get isOverdue =>
      dueDate != null &&
      status != TaskStatus.completed &&
      dueDate!.isBefore(DateTime.now());

  TaskItem copyWith({
    String? title,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      goalId: goalId,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      aiSuggestion: aiSuggestion,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, status, priority, dueDate];
}
