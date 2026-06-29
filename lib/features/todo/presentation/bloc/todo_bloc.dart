import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;
  final Connectivity connectivity;
  StreamSubscription? _connectivitySubscription;

  TodoBloc({required this.repository, required this.connectivity}) : super(TodoInitial()) {
    on<GetTodosEvent>(_onGetTodos);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<SyncTodosEvent>(_onSyncTodos);

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        add(SyncTodosEvent());
      }
    });
  }

  Future<void> _onGetTodos(GetTodosEvent event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    final result = await repository.getTodos();
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (todos) => emit(TodosLoaded(todos: todos)),
    );
  }

  Future<void> _onToggleTodo(ToggleTodoEvent event, Emitter<TodoState> emit) async {
    // Optimistic UI update
    if (state is TodosLoaded) {
      final currentTodos = (state as TodosLoaded).todos;
      final updatedTodos = currentTodos.map((t) {
        if (t.id == event.todo.id) {
          return t.copyWith(isCompleted: !t.isCompleted, isSyncPending: true);
        }
        return t;
      }).toList();
      emit(TodosLoaded(todos: updatedTodos));
    }

    final updatedTodo = event.todo.copyWith(isCompleted: !event.todo.isCompleted);
    final result = await repository.updateTodoStatus(updatedTodo);
    
    // Reload full list to ensure data consistency
    result.fold(
      (failure) => add(GetTodosEvent()), 
      (successTodo) => add(GetTodosEvent()),
    );
  }

  Future<void> _onSyncTodos(SyncTodosEvent event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      emit(TodosLoaded(todos: (state as TodosLoaded).todos, isSyncing: true));
    }
    
    await repository.syncPendingTodos();
    
    // Refresh list after sync
    add(GetTodosEvent());
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
