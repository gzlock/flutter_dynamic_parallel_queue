import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
import 'package:flutter_test/flutter_test.dart';

const taskCount = 20;

void main() {
  late int serialQueueActualTime;
  late int parallelQueueActualTime;
  test('serial queue', () async {
    final queue = Queue(parallel: 1);
    final DateTime start = DateTime.now();
    int estimated = 0;
    List.generate(taskCount, (index) async {
      final milliseconds = (index + 1) * 10;
      estimated += milliseconds;
      final value = await queue.add(() async {
        await Future.delayed(Duration(milliseconds: milliseconds));
        return milliseconds;
      });
      print('task $index done, value:$value');
    });
    await queue.whenComplete();
    final Duration end = DateTime.now().difference(start);
    serialQueueActualTime = end.inMilliseconds;
    final ratio = estimated / end.inMilliseconds;
    show(estimated, end.inMilliseconds);
    print('The two millisecond values ratio is $ratio');

    /// The actual time will definitely be more than the estimated time.
    expect(end.inMilliseconds > estimated, true);

    /// The ratio value fluctuates depending on the performance of the device.
    expect(ratio.clamp(0.85, 1.0), ratio);
  });
  test('parallel queue', () async {
    final queue = Queue(parallel: 4);
    final DateTime start = DateTime.now();
    int estimated = 0;
    List.generate(taskCount, (index) async {
      final milliseconds = (index + 1) * 10;
      estimated += milliseconds;
      final value = await queue.add(() async {
        await Future.delayed(Duration(milliseconds: milliseconds));
        return milliseconds;
      });
      print('task $index done, value:$value');
    });
    await queue.whenComplete();
    final Duration end = DateTime.now().difference(start);
    show(estimated, end.inMilliseconds);
    parallelQueueActualTime = end.inMilliseconds;
    expect(parallelQueueActualTime < serialQueueActualTime, true);
    expect(parallelQueueActualTime < estimated, true);
  });

  test('dynamic parallel queue', () async {
    final queue = Queue(parallel: 4);
    final DateTime start = DateTime.now();
    int estimated = 0;
    List.generate(taskCount, (index) async {
      final milliseconds = (index + 1) * 10;
      estimated += milliseconds;
      final value = await queue.add(() async {
        await Future.delayed(Duration(milliseconds: milliseconds));
        return milliseconds;
      });

      /// Change the parallel value of the queue to 10
      if (index == 10) queue.parallel = 10;
      print('task $index done, value:$value');
    });
    await queue.whenComplete();
    final Duration end = DateTime.now().difference(start);
    show(estimated, end.inMilliseconds);

    expect(end.inMilliseconds < estimated, true);

    /// This queue estimated time less than the last queue.
    expect(end.inMilliseconds < parallelQueueActualTime, true);
  });

  test('multi queue completers', () async {
    final queue = Queue(parallel: 10);
    List.generate(taskCount, (index) {
      final milliseconds = (index + 1) * 10;
      queue.add(() async {
        await Future.delayed(Duration(milliseconds: milliseconds));
        return milliseconds;
      });
    });
    await queue.whenComplete();
    expect(true, true);
    print('first completer');
    List.generate(taskCount, (index) {
      final milliseconds = (index + 1) * 10;
      queue.add(() async {
        await Future.delayed(Duration(milliseconds: milliseconds));
        return milliseconds;
      });
    });
    await queue.whenComplete();
    expect(true, true);
    print('second completer');
  });
}

void show(int a, int b) {
  print('All done, the estimated time is ${a}ms, the actual time is ${b}ms');
}
