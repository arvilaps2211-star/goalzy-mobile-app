import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/task_item.dart';
import '../../data/repositories/mock_task_repository.dart';
import '../../domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => MockTaskRepository());

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  final List<TaskItem> tasks;
  final bool isLoading;
  final String? error;

  List<TaskItem> get pending => tasks.where((t) => t.status != TaskStatus.completed).toList();

  List<TaskItem> get completed => tasks.where((t) => t.status == TaskStatus.completed).toList();

  List<TaskItem> get withAiSuggestions =>
      tasks.where((t) => t.aiSuggestion != null && t.status != TaskStatus.completed).toList();

  List<TaskItem> get recurring =>
      tasks.where((t) => t.isRecurring && t.status != TaskStatus.completed).toList();

  List<TaskItem> byPriority(TaskPriority priority) =>
      pending.where((t) => t.priority == priority).toList();
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier(this._repo) : super(const TasksState()) {
    loadTasks();
  }

  final TaskRepository _repo;

  Future<void> loadTasks() async {
    state = const TasksState(isLoading: true);
    try {
      final tasks = await _repo.getTasks();
      state = TasksState(tasks: tasks);
    } catch (e) {
      state = TasksState(error: e.toString());
    }
  }

  Future<TaskItem?> getTask(String id) => _repo.getTaskById(id);

  Future<void> createTask(TaskItem task) async {
    final created = await _repo.createTask(task);
    state = TasksState(tasks: [...state.tasks, created]);
  }

  Future<void> updateTask(TaskItem task) async {
    final updated = await _repo.updateTask(task);
    state = TasksState(
      tasks: state.tasks.map((t) => t.id == updated.id ? updated : t).toList(),
    );
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
    state = TasksState(tasks: state.tasks.where((t) => t.id != id).toList());
  }

  Future<void> toggleComplete(String id) async {
    final updated = await _repo.toggleTaskComplete(id);
    state = TasksState(
      tasks: state.tasks.map((t) => t.id == updated.id ? updated : t).toList(),
    );
  }
}

final tasksStateProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier(ref.watch(taskRepositoryProvider));
});

final taskByIdProvider = FutureProvider.family<TaskItem?, String>((ref, id) async {
  return ref.watch(taskRepositoryProvider).getTaskById(id);
});
