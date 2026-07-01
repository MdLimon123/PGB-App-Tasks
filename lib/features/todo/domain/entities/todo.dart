import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isSyncPending;
  final String createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.isSyncPending = false,
    required this.createdAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isSyncPending,
    String? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isSyncPending: isSyncPending ?? this.isSyncPending,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, isSyncPending, createdAt];
}
