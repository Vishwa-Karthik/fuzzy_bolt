# 🚀 FuzzyBolt - A Fast & Efficient Fuzzy Search Library for Dart

[![pub package](https://img.shields.io/pub/v/fuzzy_bolt.svg)](https://pub.dev/packages/fuzzy_bolt)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

FuzzyBolt is a high-performance fuzzy search library for Dart, designed for fast and accurate matching of search queries within large datasets. It leverages **Jaro-Winkler similarity** and **Damerau-Levenshtein distance** to provide ranked results with typo tolerance.

## ✨ Features
- 🔍 **Fast & Optimized** - Uses Jaro-Winkler and Damerau-Levenshtein for accurate matching.
- ⚡ **Isolate Support** - Automatically switches to isolates for large datasets.
- 🔢 **Configurable Thresholds** - Adjust strict and typo-matching sensitivity.
- 📝 **Easy-to-Use API** - Simple function calls with named parameters.
- 🧪 **Well-Tested** - Comes with robust test cases.

---

## 📦 Installation
Add `fuzzy_bolt` to your project's `pubspec.yaml`:

```yaml
dependencies:
  fuzzy_bolt: ^1.0.0
```

Then, run:

```sh
dart pub get
```
## 🚀 Usage Example
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

## 🛠 Output Example
```bash
Top Matches:
blackberry (Score: 0.89)
raspberry (Score: 0.85)
blueberry (Score: 0.72)
```

## ⚡ API Reference
FuzzyBolt.search({dataset, query, strictThreshold, typoThreshold}) → Future<List<Map<String, dynamic>>>

### Parameters:
🔹 dataset (List<String>) → The list of items to search through. <br>
🔹 query (String) → The search term entered by the user.<br>
🔹 strictThreshold (double, required) → The minimum Jaro-Winkler similarity score required for a match.<br>
🔹 typoThreshold (double, required) → The minimum Damerau-Levenshtein distance score required for a match.<br>

## 📚 Example Use Cases
✅ Search & Auto-Suggestions - Improve search bars with intelligent suggestions.<br>
✅ Spell Checking - Detect and correct minor spelling errors.<br>
✅ Command Line Interfaces - Enhance fuzzy matching in CLI applications.<br>
✅ Data Deduplication - Identify similar records in datasets.<br>

## 🔬 Running Tests
To ensure FuzzyBolt works correctly, run:

```sh
dart test
```

## 📜 License
This package is licensed under the MIT License. See the LICENSE file for details.

## ❤️ Contributing
Contributions are welcome! Feel free to open issues, submit PRs, or discuss improvements.

💬 Have questions? Reach out on GitHub Issues!<br>
🌟 Like this package? Give it a star on GitHub! ⭐<br>

## 🔹 Made with ❤️ by Vishwa Karthik.