import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';
import '../../shared/widgets/sc_button.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../../data/models/worker_report_model.dart';

class WorkerPendingTasksScreen extends ConsumerWidget {
  const WorkerPendingTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    final tasks = reportRepo.getPendingTasks();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Pending Tasks',
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TaskCard(task: task),
                );
              },
            ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PendingTask task;

  const _TaskCard({required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTaskIcon() {
    switch (task.taskType) {
      case 'home_visit':
        return Icons.home;
      case 'follow_up':
        return Icons.phone;
      case 'vaccination':
        return Icons.vaccines;
      case 'screening':
        return Icons.medical_services;
      default:
        return Icons.assignment;
    }
  }

  String _getTaskTypeLabel() {
    switch (task.taskType) {
      case 'home_visit':
        return 'Home Visit';
      case 'follow_up':
        return 'Follow-up Call';
      case 'vaccination':
        return 'Vaccination';
      case 'screening':
        return 'Health Screening';
      default:
        return task.taskType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now());
    final daysUntilDue = task.dueDate.difference(DateTime.now()).inDays;

    return ScCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: _getPriorityColor().withOpacity(0.2),
                child: Icon(_getTaskIcon(), color: _getPriorityColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTaskTypeLabel(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      task.patientName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Description
          Text(
            task.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Due Date
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOverdue
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning : Icons.schedule,
                  color: isOverdue ? Colors.red : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOverdue
                        ? 'Overdue by ${-daysUntilDue} days'
                        : daysUntilDue == 0
                            ? 'Due Today'
                            : 'Due in $daysUntilDue days',
                    style: TextStyle(
                      color: isOverdue ? Colors.red[700] : Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(
                    color: isOverdue ? Colors.red[700] : Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ScButton(
                    label: 'Mark Complete',
                    onPressed: () {
                      _showCompleteDialog(context);
                    },
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ScOutlineButton(
                    label: 'Reschedule',
                    onPressed: () {
                      _showRescheduleDialog(context);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Task Complete'),
        content: const Text('Are you sure you want to mark this task as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task marked as complete')),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new due date:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tomorrow'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task rescheduled to tomorrow')),
                );
              },
            ),
            ListTile(
              title: const Text('Next Week'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task rescheduled to next week')),
                );
              },
            ),
            ListTile(
              title: const Text('Custom Date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                Navigator.pop(context);
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task rescheduled to ${_formatDate(date)}'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
