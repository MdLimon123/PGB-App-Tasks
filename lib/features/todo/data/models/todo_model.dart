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

  @HiveField(4)
  final String? hiveDescription;

  @HiveField(5)
  final String hiveCreatedAt;

  const TodoModel({
    required this.hiveId,
    required this.hiveTitle,
    required this.hiveIsCompleted,
    required this.hiveIsSyncPending,
    this.hiveDescription,
    required this.hiveCreatedAt,
  }) : super(
          id: hiveId,
          title: hiveTitle,
          description: hiveDescription,
          isCompleted: hiveIsCompleted,
          isSyncPending: hiveIsSyncPending,
          createdAt: hiveCreatedAt,
        );

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      hiveId: json['id'] ?? json['_id'] ?? '',
      hiveTitle: json['title'] ?? '',
      hiveDescription: json['description'],
      hiveIsCompleted: json['is_completed'] ?? false,
      hiveIsSyncPending: false, // from API, it's always synced initially
      hiveCreatedAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'title': hiveTitle,
      'description': hiveDescription,
      'is_completed': hiveIsCompleted,
    };
  }

  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      hiveId: entity.id,
      hiveTitle: entity.title,
      hiveDescription: entity.description,
      hiveIsCompleted: entity.isCompleted,
      hiveIsSyncPending: entity.isSyncPending,
      hiveCreatedAt: entity.createdAt,
    );
  }
}

