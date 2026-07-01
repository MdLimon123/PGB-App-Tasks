import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(const LoadTodos());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          } else if (state is TodosLoaded) {
            final todos = state.todos;
            final completedCount = todos.where((t) => t.isCompleted).length;
            final totalCount = todos.length;

            // Filter todos
            final filteredTodos = _filter == 'All'
                ? todos
                : _filter == 'Pending'
                    ? todos.where((t) => !t.isCompleted).toList()
                    : todos.where((t) => t.isCompleted).toList();

            return SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'My tasks',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold,
                          color: Color(0xFF131A24)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Color(0xFFF5C6675)),
                    ),
                    const SizedBox(height: 24),

                    // Progress Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF141C28).withValues(
                              alpha: 0.05
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                              BoxShadow(
                            color: Color(0xFF141C28).withValues(
                              alpha: 0.06
                            ),
                            blurRadius: 2,
                            offset: const Offset(0, 1),                                  
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today's progress",
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Color(0xFF131A24)),
                              ),
                              Text(
                                '$completedCount of $totalCount done',  
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalCount > 0
                                  ? completedCount / totalCount
                                  : 0,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filter Tabs
                    Row(
                      children:
                          ['All', 'Pending', 'Completed'].map((filter) {
                        final isSelected = _filter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _filter = filter);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Tasks List
                    if (filteredTodos.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No $_filter tasks',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: filteredTodos.map((todo) {
                          final isCompleted = todo.isCompleted;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Circular Checkbox
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 2, right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<TodoBloc>().add(
                                            UpdateTodoStatus(
                                              id: todo.id,
                                              isCompleted: !isCompleted,
                                              updatedAt: DateTime.now()
                                                  .toIso8601String(),
                                            ),
                                          );
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCompleted
                                              ? AppTheme.primaryColor
                                              : Colors.grey.withOpacity(0.4),
                                          width: 2,
                                        ),
                                        color: isCompleted
                                            ? AppTheme.primaryColor
                                            : Colors.transparent,
                                      ),
                                      child: isCompleted
                                          ? const Icon(Icons.check,
                                              size: 18, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                ),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color:
                                              isCompleted ? Colors.grey : null,
                                        ),
                                      ),
                                      if (todo.description != null &&
                                          todo.description!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            todo.description!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      // Bottom row: time + status badge
                                      Row(
                                        children: [
                                          // Clock icon + time
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${isCompleted ? 'Done' : 'Due'} ${DateFormat('h:mm a').format(DateTime.parse(todo.createdAt))}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Status badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? AppTheme.primaryColor
                                                      .withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isCompleted
                                                  ? 'Completed'
                                                  : 'Pending',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isCompleted
                                                    ? AppTheme.primaryColor
                                                    : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          // Sync pending indicator
                                          if (todo.isSyncPending) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.cloud_off,
                                                size: 14,
                                                color: Colors.orange),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
