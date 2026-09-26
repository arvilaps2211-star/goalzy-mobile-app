import 'package:equatable/equatable.dart';

enum GoalCategory { career, health, finance, learning, personal, fitness, other }

enum GoalStatus { active, completed, paused, archived }

class GoalMilestone extends Equatable {
  const GoalMilestone({
    required this.id,
    required this.title,
    required this.targetDate,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedAt;

  GoalMilestone copyWith({bool? isCompleted, DateTime? completedAt}) {
    return GoalMilestone(
      id: id,
      title: title,
      targetDate: targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    this.progress = 0,
    this.status = GoalStatus.active,
    this.milestones = const [],
    this.colorHex = '6D5DF6',
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final DateTime targetDate;
  final double progress;
  final GoalStatus status;
  final List<GoalMilestone> milestones;
  final String colorHex;
  final DateTime? createdAt;

  int get completedMilestones => milestones.where((m) => m.isCompleted).length;

  Goal copyWith({
    String? title,
    String? description,
    double? progress,
    GoalStatus? status,
    List<GoalMilestone>? milestones,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category,
      targetDate: targetDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
      colorHex: colorHex,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, progress, status];
}
