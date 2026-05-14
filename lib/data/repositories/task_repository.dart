import '../../core/constants/storage_keys.dart';
import '../models/task_model.dart';
import '../services/local_storage_service.dart';

class TaskRepository {
  const TaskRepository(this._localStorageService);

  final LocalStorageService _localStorageService;

  bool get isStorageReady => _localStorageService.isReady;

  List<TaskModel> getTasks() {
    return _localStorageService
        .getJsonList(StorageKeys.tasksList)
        .map(TaskModel.fromJson)
        .toList();
  }

  Future<bool> saveTasks(List<TaskModel> tasks) {
    return _localStorageService.setJsonList(
      StorageKeys.tasksList,
      tasks.map((task) => task.toJson()).toList(),
    );
  }

  Future<bool> addTask(TaskModel task) async {
    final tasks = getTasks();
    final taskIndex = tasks.indexWhere(
      (storedTask) => storedTask.id == task.id,
    );
    final taskToSave = task.copyWith(updatedAt: DateTime.now());
    if (taskIndex == -1) {
      tasks.add(taskToSave);
    } else {
      tasks[taskIndex] = taskToSave;
    }
    return saveTasks(tasks);
  }

  Future<bool> updateTask(TaskModel task) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((storedTask) => storedTask.id == task.id);
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    if (index == -1) {
      tasks.add(updatedTask);
    } else {
      tasks[index] = updatedTask;
    }
    return saveTasks(tasks);
  }

  Future<bool> deleteTask(String id) {
    final tasks = getTasks()..removeWhere((task) => task.id == id);
    return saveTasks(tasks);
  }

  Future<bool> clearCompletedTasks() {
    final tasks = getTasks()..removeWhere((task) => task.isCompleted);
    return saveTasks(tasks);
  }

  Future<bool> clearAllTasks() {
    return _localStorageService.remove(StorageKeys.tasksList);
  }
}
