## Changelog

### [1.0.1] - 2025-03-08
#### Fixed
- Updated SDK constraints to support Dart `>=2.17.0 <3.7.1`.
- Excluded Web platform support due to `Isolate` API restrictions.
- Resolved `dart analyze` warnings and improved code quality.

#### Added
- Comprehensive documentation and inline comments.
- Explicit `platforms` declaration in `pubspec.yaml`.

### [1.0.0] - 2025-03-07
#### Initial Release
- Implemented **Fuzzy String Matching** using Jaro-Winkler and Damerau-Levenshtein algorithms.
- Added **fuzzy search** support with adjustable `strictThreshold` and `typoThreshold`.
- Optimized **performance using Isolates** for parallel computation.
- Provided **usage examples and test cases**.
