import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final bool isSyncPending;

  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.isSyncPending = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    bool? isSyncPending,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isSyncPending: isSyncPending ?? this.isSyncPending,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, isSyncPending];
}
