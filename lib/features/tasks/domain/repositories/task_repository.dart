import '../../../../shared/domain/entities/task_item.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasks();
  Future<TaskItem?> getTaskById(String id);
  Future<List<TaskItem>> getTasksByGoalId(String goalId);
  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(TaskItem task);
  Future<void> deleteTask(String id);
  Future<TaskItem> toggleTaskComplete(String id);
}
