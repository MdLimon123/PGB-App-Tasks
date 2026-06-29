import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

class GetTodosEvent extends TodoEvent {}

class ToggleTodoEvent extends TodoEvent {
  final Todo todo;
  const ToggleTodoEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

class SyncTodosEvent extends TodoEvent {}
