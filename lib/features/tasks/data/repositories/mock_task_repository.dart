import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/task_item.dart';
import '../../domain/repositories/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  final List<TaskItem> _tasks = List<TaskItem>.from(MockData.tasks);

  @override
  Future<List<TaskItem>> getTasks() async => List.unmodifiable(_tasks);

  @override
  Future<TaskItem?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TaskItem>> getTasksByGoalId(String goalId) async =>
      _tasks.where((t) => t.goalId == goalId).toList();

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) throw StateError('Task not found');
    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<TaskItem> toggleTaskComplete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw StateError('Task not found');

    final task = _tasks[index];
    final completed = task.status != TaskStatus.completed;
    final updated = task.copyWith(
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      completedAt: completed ? DateTime.now() : null,
    );
    _tasks[index] = updated;
    return updated;
  }
}
