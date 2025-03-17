# Fuzzy Bolt

**An advanced Fuzzy Search Algorithm with intelligent typo correction, adaptive ranking, and lightning-fast performance.**

[![pub package](https://img.shields.io/pub/v/fuzzy_bolt.svg)](https://pub.dev/packages/fuzzy_bolt)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue)](LICENSE)

## Table of Contents
- [Why Fuzzy Bolt?](#why-fuzzy-bolt)
- [Installation](#installation)
- [Usage](#usage)
  - [Normal Search](#normal-search-usage)
  - [Stream Based Search](#stream-based-search)
- [API Reference](#api-reference)
- [Platform Support](#platform-support)
- [Running Tests](#running-tests)

## Why Fuzzy Bolt ??
*I've found many packages that just purely does the fuzzy search job but haven't encountered that deals with typo/error in query automatically.*

+ Uses [Jaro–Winkler Distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) for ranking the results.
+ Uses [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance) to handle the typo errors in the query if any.
+ Automatically switch to host's [Isolate](https://dart.dev/language/isolates) mechanism if the dataset becomes huge. (Right now capped at dataset length to 500)
+ Allow developers to set their threshold on results for better accuracy.


## Installation

Add FuzzyBolt to your `pubspec.yaml`:

```yaml
dependencies:
  fuzzy_bolt: <latest_version>  
```

Then, run:

```sh
dart pub get
```

## Normal Search Usage

```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final results = await fuzzyBolt.search(
  dataset: ["encyclopedia", "phenomenon", "philosophy", "psychology"],
  query: "phsychology", // Typo: "phsychology" instead of "psychology"
  strictThreshold: 0.8,
  typoThreshold: 0.7,
);
}
```

### Output Example:

```bash
psychology (Score: 0.92)  ✅  (Fixes minor spelling mistake)
philosophy (Score: 0.75)  ❌  (Less relevant but somewhat similar)

```

## API Reference

```dart
Future<List<Map<String, dynamic>>> search({
  required List<String> dataset,
  required String query,
  double? strictThreshold,
  double? typoThreshold,
})
```

## Stream Based Search

```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final queryController = StreamController<String>();
  final searchStream = fuzzyBolt.streamSearch(
    dataset: ["apple", "banana", "berry", "grape", "pineapple"],
    query: queryController.stream,
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
## API Reference

```dart
Stream<List<Map<String, dynamic>>> streamSearch({
    required List<String> dataset,
    required Stream<String> query,
    double? strictThreshold,
    double? typoThreshold,
  });
```

## Platform Support

| Platform  | Supported |
|-----------|----------|
| Android   | ✅ Yes |
| iOS       | ✅ Yes |
| macOS     | ✅ Yes |
| Windows   | ✅ Yes |
| Linux     | ✅ Yes |
| Web       | ❌ No |

**Why no Web support?**  
*FuzzyBolt uses Dart isolates for parallel computation, which are **not supported on Flutter Web**.  I'll eventually enhance a fallback mechanism which leverages **Web Workers** for web platform.*

## Running Tests

To run tests, use:

```sh
dart test
test/fuzzy_bolt_test.dart
```
