/// Advanced fuzzy search engine with Jaro-Winkler and Levenshtein algorithms.
///
/// This library provides production-ready fuzzy searching capabilities
/// with adaptive ranking, parallel processing, and SOLID architecture.
library;

// Core API
export 'src/fuzzy_bolt.dart';

// Models
export 'src/models/fuzzy_result.dart';
export 'src/models/fuzzy_search_config.dart';
export 'src/models/search_candidate.dart';

// Algorithms (for advanced usage)
export 'src/algorithms/jaro_winkler_similarity.dart';
export 'src/algorithms/levenshtein_similarity.dart';
export 'src/algorithms/porter_stemmer.dart';
export 'src/algorithms/dataset_cleaner.dart';

// Strategies (for custom ranking)
export 'src/ranking/adaptive_ranking_strategy.dart';

// Processors (for custom processing)
export 'src/processing/synchronous_processor.dart';
export 'src/processing/isolate_parallel_processor.dart';
