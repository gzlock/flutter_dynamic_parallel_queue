library dynamic_parallel_queue;

import 'dart:async';

typedef Task = Future<dynamic> Function();

class _Task {
  final Task task;
  final Completer completer = Completer();

  _Task(this.task);
}

class Queue {
  int _parallel;

  /// 执行中的任务
  final List<Future> _progressing = [];

  /// 等待执行的任务
  final List<_Task> _pending = [];

  Completer _completer = Completer();

  Queue({int parallel = 5}) : _parallel = parallel;

  int get parallel => _parallel;

  set parallel(int value) {
    _parallel = value;
    _execute();
  }

  /// Add new task
  Future add(Task task) async {
    final _task = _Task(task);
    _pending.add(_task);
    _execute();
    return _task.completer.future;
  }

  /// Execute new task
  void _execute() {
    // print('_execute ${{
    //   'parallel': parallel,
    //   'executes': _progressing.length,
    //   'waits': _pending.length
    // }}');

    /// all done
    if (_progressing.isEmpty && _pending.isEmpty) {
      // print('_execute all done');
      _completer.complete();
      _completer = Completer();
      return;
    }

    /// No pending tasks
    if (_pending.isEmpty) return;

    /// The number of tasks in progress is greater than parallel
    if (_progressing.length >= _parallel) return;

    final task = _pending.removeAt(0);
    late Future future;
    future = Future(() async {
      try {
        final value = await task.task();
        task.completer.complete(value);
      } catch (e) {
        task.completer.completeError(e);
      } finally {
        _progressing.remove(future);
        _execute();
      }
    });
    _progressing.add(future);
    _execute();
  }

  /// Clear all pending tasks
  void clear() {
    _pending.clear();
    _execute();
  }

  Future whenComplete() => _completer.future;
}
