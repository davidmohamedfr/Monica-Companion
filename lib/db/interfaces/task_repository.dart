import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/task.dart';

/// Repository interface for Task entities
abstract class TaskRepository implements RepositoryInterface<Task, int> {
  /// Find tasks for a specific contact
  Future<List<Task>> findByContactId(int contactId);

  /// Find completed tasks
  Future<List<Task>> findCompleted();

  /// Find pending (not completed) tasks
  Future<List<Task>> findPending();

  /// Find tasks by priority level
  Future<List<Task>> findByPriority(int priority);

  /// Find overdue tasks (past due date and not completed)
  Future<List<Task>> findOverdue();

  /// Find tasks due within a date range
  Future<List<Task>> findByDateRange(DateTime start, DateTime end);

  /// Find tasks by priority range
  Future<List<Task>> findByPriorityRange(int minPriority, int maxPriority);

  /// Find upcoming tasks (due within next N days)
  Future<List<Task>> findUpcoming(int daysAhead);

  /// Count tasks for a contact
  Future<int> countByContactId(int contactId);

  /// Count completed tasks for a contact
  Future<int> countCompletedByContactId(int contactId);

  /// Count pending tasks for a contact
  Future<int> countPendingByContactId(int contactId);
}