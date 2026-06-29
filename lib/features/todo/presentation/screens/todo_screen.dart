import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(GetTodosEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks', style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodosLoaded && state.isSyncing) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: Icon(Icons.sync, color: theme.iconTheme.color),
                onPressed: () {
                  context.read<TodoBloc>().add(SyncTodosEvent());
                },
              );
            },
          )
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is TodosLoaded) {
            if (state.todos.isEmpty) {
              return const Center(child: Text('No tasks available.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final todo = state.todos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    activeColor: theme.primaryColor,
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: todo.isSyncPending
                        ? const Row(
                            children: [
                              Icon(Icons.cloud_off, size: 12, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('Pending Sync', style: TextStyle(fontSize: 12, color: Colors.orange)),
                            ],
                          )
                        : null,
                    value: todo.isCompleted,
                    onChanged: (val) {
                      context.read<TodoBloc>().add(ToggleTodoEvent(todo));
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
