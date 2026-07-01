import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../todo/presentation/bloc/todo_bloc.dart';
import '../../../todo/presentation/bloc/todo_state.dart';
import '../../../todo/presentation/bloc/todo_event.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Status', style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            int pendingCount = 0;
            if (state is TodosLoaded) {
              pendingCount = state.todos.where((t) => t.isSyncPending).length;
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  pendingCount > 0 ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
                  size: 80,
                  color: pendingCount > 0 ? Colors.orange : theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  pendingCount > 0 ? '$pendingCount items pending sync' : 'All data is synced',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                if (pendingCount > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TodoBloc>().add(SyncTodosEvent());
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
