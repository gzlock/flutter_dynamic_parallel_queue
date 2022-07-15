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

```dart
void main() async {
  final queue = Queue(parallel: 1); // Serial queue

  queue.add(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 100;
  }).then((value) {
    print('task done, value:$value');
  });

  /// You can change the parallel value of the queue at any time
  /// Including while there are still tasks executing
  queue.parallel = 10; // Change to parallel queue

  List.generate(20, (index) async {
    index += 1;
    final milliseconds = index * 10;
    final value = await queue.add(() async {
      await Future.delayed(Duration(milliseconds: milliseconds));
      return milliseconds;
    });
    print('task $index done, value:$value');
  });


  /// Clear all pending tasks
  // queue.clear();

  /// Wait for the queue to complete
  await queue.whenComplete();
  print('All done');
}
```