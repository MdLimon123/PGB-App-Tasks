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
  bool _isOnline = true;

  TodoBloc({required this.repository, required this.connectivity})
      : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<UpdateTodoStatus>(_onUpdateTodoStatus);
    on<SyncTodosEvent>(_onSyncTodos);
    on<RefreshTodos>(_onRefreshTodos);
    on<ClearSyncPending>(_onClearSyncPending);

    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      // When connection is restored, sync pending todos
      if (!wasOnline && _isOnline) {
        add(SyncTodosEvent());
      }
    });
  }

  Future<void> _onLoadTodos(
    LoadTodos event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      final result = await repository.getTodos();
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (todos) => emit(TodosLoaded(todos: todos, isSyncing: false)),
      );
    } catch (e) {
      emit(TodoError('Failed to load todos'));
    }
  }

  Future<void> _onUpdateTodoStatus(
    UpdateTodoStatus event,
    Emitter<TodoState> emit,
  ) async {
    if (state is! TodosLoaded) return;

    final currentState = state as TodosLoaded;
    final currentTodos = currentState.todos;

    // Find and update the todo
    final todoIndex = currentTodos.indexWhere((t) => t.id == event.id);
    if (todoIndex == -1) return;

    // Create updated todo
    final updatedTodo = currentTodos[todoIndex].copyWith(
      isCompleted: event.isCompleted,
      isSyncPending: !_isOnline,
    );

    final updatedTodos = [...currentTodos];
    updatedTodos[todoIndex] = updatedTodo;

    // Optimistic UI update
    emit(TodosLoaded(todos: updatedTodos, isSyncing: true));

    // Try to sync immediately if online
    if (_isOnline) {
      final result =
          await repository.updateTodoStatus(updatedTodo);
      result.fold(
        (failure) {
          // Revert on error
          emit(TodosLoaded(todos: currentTodos, isSyncing: false));
        },
        (_) {
          // Keep updated state
          emit(TodosLoaded(todos: updatedTodos, isSyncing: false));
        },
      );
    } else {
      // Mark as pending sync
      emit(TodosLoaded(
        todos: updatedTodos,
        isSyncing: false,
      ));
    }
  }

  Future<void> _onSyncTodos(
    SyncTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (!_isOnline) return;
    if (state is! TodosLoaded) return;

    final currentState = state as TodosLoaded;
    emit(TodosLoaded(todos: currentState.todos, isSyncing: true));

    // Sync pending todos
    if (currentState.todos.any((t) => t.isSyncPending)) {
      final result = await repository.syncPendingTodos();

      result.fold(
        (failure) {
          emit(TodosLoaded(todos: currentState.todos, isSyncing: false));
        },
        (_) {
          // Clear sync pending flags
          final syncedTodos = currentState.todos
              .map((t) => t.copyWith(isSyncPending: false))
              .toList();
          emit(TodosLoaded(todos: syncedTodos, isSyncing: false));
        },
      );
    } else {
      emit(TodosLoaded(todos: currentState.todos, isSyncing: false));
    }
  }

  Future<void> _onRefreshTodos(
    RefreshTodos event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodosLoaded) {
      final currentState = state as TodosLoaded;
      emit(TodosLoaded(todos: currentState.todos, isSyncing: true));
    } else {
      emit(TodoLoading());
    }

    final result = await repository.getTodos();
    result.fold(
      (failure) => emit(TodoError(failure.message)),
      (todos) => emit(TodosLoaded(todos: todos, isSyncing: false)),
    );
  }

  Future<void> _onClearSyncPending(
    ClearSyncPending event,
    Emitter<TodoState> emit,
  ) async {
    if (state is! TodosLoaded) return;

    final currentState = state as TodosLoaded;
    final clearedTodos = currentState.todos
        .map((t) => t.copyWith(isSyncPending: false))
        .toList();

    emit(TodosLoaded(todos: clearedTodos, isSyncing: false));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
