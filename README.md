<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Dynamic Parallel Queue

## Features

Easy to use(so, no example project folder), Efficient, Pure

## Getting started

```dart
import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
```

## Usage

### Serial queue

```dart
void main() async {
  // Now it's a serial queue, parallel default is 5
  final queue = Queue(parallel: 1);
  
  final List<int> res = [];

  // Add a async function, return Future
  final task1 = queue.add(() async {
    await Future.delayed(Duration(milliseconds: 30));
    res.add(1);
  });
  // You can wait it done.
  await task1;

  // add a list, return Future
  final tasks = queue.addAll([
    () async {
      await Future.delayed(Duration(milliseconds: 20));
      res.add(2);
    },
    () async {
      await Future.delayed(Duration(milliseconds: 10));
      res.add(3);
    },
  ]);

  /// You can wait for the tasks to complete
  /// But not need here
  // await tasks;


  /// Remove all pending tasks
  // queue.clear();

  /// Wait for the queue to complete
  await queue.whenComplete();
}
```

Although their wait times are different, buy they are executed in order.

Console output: `[1, 2, 3]`

### Parallel Queue

```dart
void main() async {
  final queue = Queue();
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

  /// Wait for the queue to complete
  await queue.whenComplete();
}
```

Console output `[3, 2, 1]`

### Serial queue change to parallel queue

```dart
void main() async {
  final queue = Queue(parallel: 1);
  final List<int> res = [];
  final task1 = queue.add(() async {
    await Future.delayed(Duration(milliseconds: 50));
    
    /// You can change it at any time.
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
  print(res);
}
```

Console output `[1, 4, 3, 2]`