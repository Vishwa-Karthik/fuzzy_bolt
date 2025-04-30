# Fuzzy Bolt

**An advanced Fuzzy Search Algorithm with intelligent typo correction, adaptive ranking, and lightning-fast performance.**

[![pub package](https://img.shields.io/pub/v/fuzzy_bolt.svg)](https://pub.dev/packages/fuzzy_bolt)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue)](LICENSE)

## Table of Contents
- [Why Fuzzy Bolt?](#why-fuzzy-bolt-??)

- [Use Case Applications](#Use-Case-Applications)

- [Installation](#installation)

- [Usage](#usage)
  - [Normal Search](#normal-search-usage)
  - [Normal Search with Ranks](#normal-search-with-ranks)
  - [Stream Based Search](#stream-based-search)
  - [Stream-Based Search with Ranks](#stream-based-search-with-ranks)

- [API Reference](#api-reference)

- [Platform Support](#platform-support)

- [Running Tests](#running-tests)



## Why Fuzzy Bolt ??
*I've found many packages that just purely does the fuzzy search job but haven't encountered that deals with typo/error in query automatically.*

+ Uses [Jaro–Winkler Distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) for ranking the results.
+ Uses [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance) to handle the typo errors in the query if any.
+ Leverage host's [Isolate](https://dart.dev/language/isolates) mechanism if the dataset becomes huge.
+ Automatically switch to non-isolate fallback mechanim for Web platform.
+ Allow developers to set their threshold on results for better accuracy.

## Use Case Applications

- **Local Database Search**:
Perfect for running fuzzy queries directly on local datasets like SQLite, Hive, or Isar.

- **Post-API Result Search**:
Enhance your UX by adding an extra layer of fuzzy search after fetching data from remote APIs.

- **In-Memory State Search**:
Great for filtering and ranking results from app state (e.g in-memory lists, BLoC/Cubit states, Provider data, etc.).

- **Search Bars & Autocomplete Fields**:
Supercharge your TextField or SearchDelegate with typo-tolerant and intent-aware results.

- **Offline-First Applications**:
Helpful in apps that prioritize offline functionality and require local, fast search.

- **Data Cleaning & Record Linking**:
Use it for fuzzy matching and deduplication tasks (e.g., merging similar records in datasets).

- **Command Palette / Quick Actions Search**:
Perfect for developer tools or admin dashboards where users trigger commands via text input.

## Installation

Add FuzzyBolt to your `pubspec.yaml`:

```yaml
dependencies:
  fuzzy_bolt: <latest_version>  
```

Then, run:

```sh
flutter pub get
```

## Normal Search Usage

### API Reference

```dart
Future<List<String>> search({
  required List<String> dataset,
  required String query,
  double? strictThreshold,
  double? typoThreshold,
  bool? kIsWeb,
})
```

### Example
```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final results = await FuzzyBolt().search(
  dataset: ["encyclopedia", "phenomenon", "philosophy", "psychology"],
  query: "phsychology", // Typo: "phsychology" instead of "psychology"
  strictThreshold: 0.8,
  typoThreshold: 0.7,
  kIsWeb: false,
);

  results.map((e) => print(e)).toList();
}
```

### Output Example:

```bash
psychology 

philosophy 
```

## Normal Search with Ranks

### API Reference

```dart
Future<List<Map<String, dynamic>>> searchWithRanks({
  required List<String> dataset,
  required String query,
  double? strictThreshold,
  double? typoThreshold,
  bool? kIsWeb,
  Function(Object, StackTrace)? onError,
})
```

### Example
```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final results = await FuzzyBolt().searchWithRanks(
    dataset: ["encyclopedia", "phenomenon", "philosophy", "psychology"],
    query: "phsychology", // Typo: "phsychology" instead of "psychology"
    strictThreshold: 0.8,
    typoThreshold: 0.7,
    kIsWeb: false,
    Function(Object, StackTrace)? onError,
  );

  print("Results with ranks:");
  for (var result in results) {
    print("${result['value']} (Score: ${result['rank']})");
  }
}
```

### Output Example:

```bash
psychology (Score: 0.92)  ✅  (Fixes minor spelling mistake)
philosophy (Score: 0.75)  ❌  (Less relevant but somewhat similar)
```



## Stream Based Search

### API Reference

```dart
Stream<List<String>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
    Function(Object, StackTrace)? onError,
  });
```

### Example
```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final queryController = StreamController<String>();
  final searchStream = fuzzyBolt.streamSearch(
    dataset: ["apple", "banana", "berry", "grape", "pineapple"],
    query: queryController.stream,
    Function(Object, StackTrace)? onError,
  );

  searchStream.listen((results) {
    print(results);
  });

  queryController.add("b");
  queryController.add("be");
  queryController.add("ber");
  queryController.add("berr");
  queryController.add("berry");
}

```
### Output Example:

```bash
🚀 Running Stream-Based Search...

⌨️ Typing: 'b'
🔄 Stream Update:
   🔹 banana (Score: 0.750)
   🔹 blueberry (Score: 0.733)
   🔹 blackberry (Score: 0.730)

⌨️ Typing: 'be'
🔄 Stream Update:
   🔹 blueberry (Score: 0.767)

⌨️ Typing: 'ber'
🔄 Stream Update:
   🔹 blueberry (Score: 0.667)
   🔹 tangerine (Score: 0.630)
   🔹 watermelon (Score: 0.622)
   🔹 pomegranate (Score: 0.616)

⌨️ Typing: 'berr'
🔄 Stream Update:
   🔹 blueberry (Score: 0.725)
   🔹 blackberry (Score: 0.610)

⌨️ Typing: 'berry'
🔄 Stream Update:
   🔹 blueberry (Score: 0.680)
   🔹 raspberry (Score: 0.444)
🏁 Stream-based search completed.
```

## Stream-Based Search with Ranks

### API Reference

```dart
Stream<List<Map<String, dynamic>>> streamSearchWithRanks({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
    bool? kIsWeb,
    Function(Object, StackTrace)? onError,
  });
```

### Example
```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final queryController = StreamController<String>();
  final searchStream = fuzzyBolt.streamSearchWithRanks(
    dataset: ["apple", "banana", "berry", "grape", "pineapple"],
    query: queryController.stream,
  );

  searchStream.listen((results) {
    print("Results with ranks:");
    for (var result in results) {
      print("${result['value']} (Score: ${result['rank']})");
    }
  });

  queryController.add("b");
  queryController.add("be");
  queryController.add("ber");
  queryController.add("berr");
  queryController.add("berry");
}
```

### Output Example:

```bash
🚀 Running Stream-Based Search with Ranks...

⌨️ Typing: 'b'
🔄 Stream Update:
   🔹 banana (Score: 0.750)
   🔹 blueberry (Score: 0.733)
   🔹 blackberry (Score: 0.730)

⌨️ Typing: 'be'
🔄 Stream Update:
   🔹 blueberry (Score: 0.767)

⌨️ Typing: 'ber'
🔄 Stream Update:
   🔹 blueberry (Score: 0.667)
   🔹 blackberry (Score: 0.610)

⌨️ Typing: 'berry'
🔄 Stream Update:
   🔹 blueberry (Score: 0.680)
   🔹 raspberry (Score: 0.444)
```

## Platform Support

| Platform  | Supported |
|-----------|----------|
| Android   | ✅ Yes |
| iOS       | ✅ Yes |
| macOS     | ✅ Yes |
| Windows   | ✅ Yes |
| Linux     | ✅ Yes |
| Web       | ✅ Yes |

**Web support?**  
*I've added fallback mechanism to use search locally without the help of Isolate mechanism since Flutter web do not support Isolates...*

### Note on `streamSearch` Stability

The `onError` callback in `streamSearch` is designed to handle errors gracefully. However, in certain edge cases (e.g., invalid datasets or rapidly changing queries), the behavior may be inconsistent. It is recommended to test thoroughly for your specific use case and handle errors at the application level if needed.

## Running Tests

To run tests, use:

```sh
dart test
test/fuzzy_bolt_test.dart
```
