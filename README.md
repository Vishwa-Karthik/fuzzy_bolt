# FuzzyBolt 🔥

**A powerful and optimized fuzzy search algorithm with typo tolerance and ranking.**

[![pub package](https://img.shields.io/pub/v/fuzzy_bolt.svg)](https://pub.dev/packages/fuzzy_bolt)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue)](LICENSE)

## Features
✅ **Blazing Fast Performance** 🚀  
✅ **Advanced String Matching with Jaro-Winkler & Levenshtein Distance**  
✅ **Ideal for Autocomplete, Search Bars, and Query Refinement**  
✅ **Asynchronous & Optimized for Large Datasets**

## 📦 Installation

Add FuzzyBolt to your `pubspec.yaml`:

```yaml
dependencies:
  fuzzy_bolt: <latest_version>  
```

Then, run:

```sh
dart pub get
```

## 📖 Usage

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

### 🛠 Output Example:

```
psychology (Score: 0.92)  ✅  (Fixes minor spelling mistake)
philosophy (Score: 0.75)  ❌  (Less relevant but somewhat similar)

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
- Open an issue on [GitHub](https://github.com/Vishwa-Karthik/fuzzy_bolt/issues)
- Submit a pull request
- Suggest new features or report bugs

## 💬 Questions?

If you have any questions, feel free to open a discussion on GitHub or raise an issue.

🌟 **Like this package? Star it on GitHub!** ⭐


## 🔹 Made with ❤️ by Vishwa Karthik.