import 'package:hive/hive.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<List<TodoModel>> getCachedTodos();
  Future<void> updateTodo(TodoModel todo);
  Future<List<TodoModel>> getPendingSyncTodos();
  Future<void> clearPendingSyncStatus(List<String> ids);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static const String _boxName = 'todos_box';

  Future<Box<TodoModel>> get _box async => await Hive.openBox<TodoModel>(_boxName);

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final box = await _box;
    final Map<String, TodoModel> todoMap = {
      for (var todo in todos) todo.hiveId: todo
    };
    
    // Merge updates: preserve pending sync items
    for (var key in box.keys) {
      final existing = box.get(key);
      if (existing != null && existing.hiveIsSyncPending) {
         if(todoMap.containsKey(existing.hiveId)) {
            // Keep local version if it has pending changes
            todoMap[existing.hiveId] = existing;
         }
      }
    }
    
    await box.clear();
    await box.putAll(todoMap);
  }

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    final box = await _box;
    await box.put(todo.hiveId, todo);
  }

  @override
  Future<List<TodoModel>> getPendingSyncTodos() async {
    final box = await _box;
    return box.values.where((todo) => todo.hiveIsSyncPending).toList();
  }

  @override
  Future<void> clearPendingSyncStatus(List<String> ids) async {
    final box = await _box;
    for (var id in ids) {
      final todo = box.get(id);
      if (todo != null) {
        final syncedTodo = TodoModel(
          hiveId: todo.hiveId,
          hiveTitle: todo.hiveTitle,
          hiveIsCompleted: todo.hiveIsCompleted,
          hiveIsSyncPending: false,
        );
        await box.put(id, syncedTodo);
      }
    }
  }
}
