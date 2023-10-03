import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serial queue', () async {
    final queue = Queue(parallel: 1);
    final List<int> res = [];
    queue.addAll([
      () async {
        await Future.delayed(Duration(milliseconds: 30));
        res.add(1);
      },
      () async {
        await Future.delayed(Duration(milliseconds: 20));
        res.add(2);
      },
      () async {
        await Future.delayed(Duration(milliseconds: 10));
        res.add(3);
      },
    ]);
    await queue.whenComplete();
    expect(res, [1, 2, 3]);
  });
  test('parallel queue', () async {
    final queue = Queue(parallel: 5);
    final List<int> res = [];
    queue.addAll([
      () async {
        await Future.delayed(Duration(milliseconds: 30));
        res.add(1);
      },
      () async {
        await Future.delayed(Duration(milliseconds: 20));
        res.add(2);
      },
      () async {
        await Future.delayed(Duration(milliseconds: 10));
        res.add(3);
      },
    ]);
    await queue.whenComplete();
    expect(res, [3, 2, 1]);
  });

  test('Serial queue change to parallel queue', () async {
    final queue = Queue(parallel: 1);
    final List<int> res = [];
    final task1 = queue.add(() async {
      await Future.delayed(Duration(milliseconds: 50));
      queue.parallel = 5;
      res.add(1);
    });
    await task1;
    queue.addAll([
      () async {
        await Future.delayed(Duration(milliseconds: 30));
        res.add(2);
      },
      () async {
        await Future.delayed(Duration(milliseconds: 20));
        res.add(3);
      },
      () async {
        await Future.delayed(Duration(milliseconds: 10));
        res.add(4);
      },
    ]);
    await queue.whenComplete();
    expect(res, [1, 4, 3, 2]);
  });
  test('priority test', () async {
    final queue = Queue(parallel: 2);
    final List<int> res = [];
    queue.addAll([
      () async => res.add(1),
      () async => res.add(2),
    ], priority: 10);
    queue.add(() async => res.add(3), priority: 3);
    queue.add(() async => res.add(4), priority: 2);
    queue.add(() async => res.add(0), priority: -1); // Support negative priority
    await queue.whenComplete();
    expect(res, [1, 2, 0, 4, 3]);
  });
}
