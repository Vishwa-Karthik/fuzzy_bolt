# Fuzzy Bolt

**An advanced Fuzzy Search Algorithm with intelligent typo correction, adaptive ranking, and lightning-fast performance.**

[![pub package](https://img.shields.io/pub/v/fuzzy_bolt.svg)](https://pub.dev/packages/fuzzy_bolt)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue)](LICENSE)

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

### Basic Usage

```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

// Your data model
class User {
  final String name;
  final String email;

  const User(this.name, this.email);
}

final users = [
  const User("Alice Johnson", "alice@example.com"),
  const User("Bob Smith", "bob@sample.com"),
  const User("Charlie Brown", "charlie@hello.com"),
];

// Simple search - returns matching items
final results = await FuzzyBolt.search<User>(
  users,
  "alice",
  selectors: [(u) => u.name, (u) => u.email],
);

// Search with scores - returns items with similarity scores
final scoredResults = await FuzzyBolt.searchWithScores<User>(
  users,
  "alise", // typo tolerance
  selectors: [(u) => u.name],
  strictThreshold: 0.85,
  typeThreshold: 0.65,
);

for (final result in scoredResults) {
  print("${result.item.name} -> ${(result.score * 100).toStringAsFixed(1)}% match");
}
```

## 📋 API Reference

### Core Methods

#### `FuzzyBolt.search<T>()`

Returns matching items directly.

```dart
Future<List<T>> search<T>(
  List<T> dataset,
  String query, {
  required List<String Function(T)> selectors,
  double strictThreshold = 0.85,
  double typeThreshold = 0.65,
  int isolateThreshold = 1000,
  bool skipIsolate = false,
  int? maxResults,
})
```

#### `FuzzyBolt.searchWithScores<T>()`

Returns matching items with similarity scores and matched text.

```dart
Future<List<FuzzyResult<T>>> searchWithScores<T>(
  List<T> dataset,
  String query, {
  required List<String Function(T)> selectors,
  double strictThreshold = 0.85,
  double typeThreshold = 0.65,
  int isolateThreshold = 1000,
  bool skipIsolate = false,
  int? maxResults,
})
```

#### `FuzzyBolt.searchWithConfig<T>()`

Search using a configuration object for advanced control.

```dart
Future<List<FuzzyResult<T>>> searchWithConfig<T>(
  List<T> dataset,
  String query,
  List<String Function(T)> selectors,
  FuzzySearchConfig config,
)
```

### Configuration

#### `FuzzySearchConfig`

Fine-tune search behavior:

```dart
final config = FuzzySearchConfig(
  strictThreshold: 0.9,      // Higher = more exact matches required
  typeThreshold: 0.6,        // Lower = more typo tolerance
  isolateThreshold: 1500,    // Dataset size to trigger parallel processing
  skipIsolate: false,        // Force disable isolates (required for web)
  maxResults: 100,           // Limit number of results
);
```

### Results

#### `FuzzyResult<T>`

Contains search result with metadata:

```dart
class FuzzyResult<T> {
  final T item;              // Original item from dataset
  final double score;        // Similarity score (0.0 - 1.0)
  final String matchedText;  // Text that was matched
}
```

## 🔧 Advanced Usage

### Multi-Field Search

Search across multiple fields with different weights:

```dart
class Product {
  final String name;
  final String category;
  final String description;
  // ...
}

final results = await FuzzyBolt.searchWithScores<Product>(
  products,
  "laptop pro",
  selectors: [
    (p) => p.name,        // Primary field
    (p) => p.category,    // Secondary field
    (p) => p.description, // Tertiary field
  ],
  typeThreshold: 0.5,
);
```

### Performance Optimization

For large datasets, FuzzyBolt automatically uses isolates:

```dart
// Automatic parallel processing for datasets > 1000 items
final results = await FuzzyBolt.search<User>(
  largeUserList, // 10,000+ users
  "john doe",
  selectors: [(u) => u.name],
  isolateThreshold: 1000, // Customize threshold
);
```

## 🌐 Web Compatibility

FuzzyBolt is fully web-compatible. Isolates are automatically disabled on web platforms:

```dart
// Automatically detects web environment and disables isolates
final results = await FuzzyBolt.search<User>(
  users,
  "search query",
  selectors: [(u) => u.name],
   skipIsolate: true,  // Set this to TRUE if Platform.isWeb
);
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

**Built with ❤️ by the Dart community**