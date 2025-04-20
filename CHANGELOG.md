## Changelog

### [1.1.8] - 2025-04-20

#### Added
- Introduced `streamSearchWithRanks` API for stream-based search with ranking support.
- Introduced `searchWithRanks` API to provide ranked results for normal searches.

#### Changed
- updated `search` and `streamSearch` results in [List<String>] instead of [Map] without ranks for easier check.

#### Fixed
- Resolved issue where incorrect mapping of results caused empty lists in `streamSearch`.

---


### [1.1.7] - 2025-04-20

#### Fixed
- Rectified the correct export methods.
---

### [1.1.6] - 2025-03-22

#### Added
- Added web platform support.
- Updated README to help developers understand the necessity and use case of this application.

#### Changed
- Added web fallback mechanism to run without the use of Isolates.

---

### [1.1.5] - 2025-03-16

#### Changed
- Updated README for better documentation.
- Project-level indentation and formatter.

---

### [1.1.4] - 2025-03-16

#### Changed
- Dart SDK Version conflict resolved.
- Updated README for better understanding.

---

### [1.1.3] - 2025-03-14

#### Added
- Updated Documentation.

#### Changed
- Enhanced the search and ranking algorithm for better performance.
- Reduced Isolate fallback dependency from 1000 length to 500.

---

### [1.1.2] - 2025-03-11

#### Changed
- Enhanced stream-based fuzzy search for improved responsiveness.
- Optimized event handling to ensure seamless updates when queries change.
- Improved case-insensitive matching for better search accuracy.

#### Fixed
- Resolved issue where empty search results were not emitted correctly.
- Addressed inconsistencies in asynchronous search streaming.
- Fine-tuned ranking algorithm for better precision in result ordering.

#### Added
- Introduced unit tests for stream-based search to ensure reliability.
- Expanded debug logging to assist with troubleshooting and performance tuning.
- Added support for wildcard searches to broaden query flexibility.

---

### [1.0.2] - 2025-03-10

#### Changed
- Refactored project structure to align with **SOLID principles**.
- Implemented **abstract class `FuzzyBolt`** with `search`.

#### Fixed
- Optimized search ranking for improved fuzzy matching accuracy.
- Addressed minor inconsistencies in **Jaro-Winkler and Levenshtein** handling.

---

### [1.0.1] - 2025-03-08

#### Fixed
- Updated SDK constraints to support Dart `>=2.17.0 <3.7.1`.
- Excluded Web platform support due to `Isolate` API restrictions.
- Resolved `dart analyze` warnings and improved code quality.

#### Added
- Comprehensive documentation and inline comments.
- Explicit `platforms` declaration in `pubspec.yaml`.

---

### [1.0.0] - 2025-03-07

#### Initial Release
- Implemented **Fuzzy String Matching** using Jaro-Winkler and Damerau-Levenshtein algorithms.
- Added **fuzzy search** support with adjustable `strictThreshold` and `typoThreshold`.
- Optimized **performance using Isolates** for parallel computation.
- Provided **usage examples and test cases**.