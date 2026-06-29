import 'package:hive/hive.dart';
import '../../domain/entities/todo.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends Todo {
  @HiveField(0)
  final String hiveId;

  @HiveField(1)
  final String hiveTitle;

  @HiveField(2)
  final bool hiveIsCompleted;

  @HiveField(3)
  final bool hiveIsSyncPending;

  const TodoModel({
    required this.hiveId,
    required this.hiveTitle,
    required this.hiveIsCompleted,
    required this.hiveIsSyncPending,
  }) : super(
          id: hiveId,
          title: hiveTitle,
          isCompleted: hiveIsCompleted,
          isSyncPending: hiveIsSyncPending,
        );

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      hiveId: json['id'] ?? json['_id'] ?? '',
      hiveTitle: json['title'] ?? '',
      hiveIsCompleted: json['is_completed'] ?? false,
      hiveIsSyncPending: false, // from API, it's always synced initially
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'title': hiveTitle,
      'is_completed': hiveIsCompleted,
    };
  }

  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      hiveId: entity.id,
      hiveTitle: entity.title,
      hiveIsCompleted: entity.isCompleted,
      hiveIsSyncPending: entity.isSyncPending,
    );
  }
}
