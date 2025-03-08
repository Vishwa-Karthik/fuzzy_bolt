# FuzzyBolt 🔥

**A powerful and optimized fuzzy search algorithm with typo tolerance and ranking.**

[![pub package](https://img.shields.io/pub/v/fuzzy_bolt.svg)](https://pub.dev/packages/fuzzy_bolt)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue)](LICENSE)

## 🚀 Features

- **Fast and accurate fuzzy search** powered by Jaro-Winkler and Damerau-Levenshtein algorithms.
- **Typo tolerance** for handling spelling mistakes.
- **Ranking system** to prioritize better matches.
- **Asynchronous processing** using Dart isolates.
- **Lightweight and easy to use**.

## 📦 Installation

Add FuzzyBolt to your `pubspec.yaml`:

```yaml
dependencies:
  fuzzy_bolt: latest_version
```

Then, run:

```sh
dart pub get
```

## 📖 Usage

```dart
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  final fuzzyBolt = FuzzyBolt();

  List<String> dataset = [
    "apple",
    "banana",
    "grapefruit",
    "strawberry",
    "raspberry",
    "blackberry",
    "blueberry",
    "pineapple",
  ];

  final results = await fuzzyBolt.search(
    dataset: dataset,
    query: "black rasp",
    strictThreshold: 0.85,
    typoThreshold: 0.7,
  );

  print("Top Matches:");
  for (var result in results) {
    print("${result['value']} (Score: ${result['rank']})");
  }
}
```

### 🛠 Output Example:

```
Top Matches:
blackberry (Score: 0.89)
raspberry (Score: 0.85)
blueberry (Score: 0.72)
```

## ⚡ API Reference

```dart
Future<List<Map<String, dynamic>>> search({
  required List<String> dataset,
  required String query,
  required double strictThreshold,
  required double typoThreshold,
})
```

| Parameter          | Type     | Description |
|------------------|---------|-------------|
| `dataset`        | `List<String>` | The list of items to search through. |
| `query`          | `String` | The search term entered by the user. |
| `strictThreshold` | `double` | Minimum Jaro-Winkler similarity score required for a match. |
| `typoThreshold`  | `double` | Minimum Damerau-Levenshtein distance score required for a match. |

## 📚 Use Cases

✅ **Search & Auto-Suggestions** - Enhance search bars with intelligent suggestions.  
✅ **Spell Checking** - Detect and correct minor spelling errors.  
✅ **Command Line Interfaces** - Improve fuzzy matching in CLI applications.  
✅ **Data Deduplication** - Identify similar records in datasets.  

## 🔥 Platform Support

| Platform  | Supported |
|-----------|----------|
| Android   | ✅ Yes |
| iOS       | ✅ Yes |
| macOS     | ✅ Yes |
| Windows   | ✅ Yes |
| Linux     | ✅ Yes |
| Web       | ❌ No |

**Why no Web support?**  
FuzzyBolt uses Dart isolates for parallel computation, which are **not supported on Flutter Web**.  I'll eventually enhance a fallback mechanism which leverages **Web Workers** for web platform.

## 🔬 Running Tests

To run tests, use:

```sh
dart test
test/fuzzy_bolt_test.dart
```

## 📜 License

This package is licensed under the **BSD-3-Clause License**. See the [LICENSE](LICENSE) file for details.

## ❤️ Contributing

We welcome contributions! If you'd like to improve FuzzyBolt:
- Open an issue on [GitHub](https://github.com/your-repo/fuzzy_bolt/issues)
- Submit a pull request
- Suggest new features or report bugs

## 💬 Questions?

If you have any questions, feel free to open a discussion on GitHub or raise an issue.

🌟 **Like this package? Star it on GitHub!** ⭐


## 🔹 Made with ❤️ by Vishwa Karthik.