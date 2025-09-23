/// Advanced fuzzy search engine with Jaro-Winkler and Levenshtein algorithms.
///
/// This library provides production-ready fuzzy searching capabilities
/// with adaptive ranking, parallel processing, and SOLID architecture.
library fuzzy_bolt;

// Core API
export 'src/fuzzy_bolt.dart';

// Models
export 'src/models/fuzzy_result.dart';
export 'src/models/fuzzy_search_config.dart';
export 'src/models/search_candidate.dart';

// Interfaces (for advanced usage)
export 'src/interfaces/similarity_algorithm.dart';
export 'src/interfaces/ranking_strategy.dart';
export 'src/interfaces/parallel_processor.dart';

// Algorithms (for custom implementations)
export 'src/algorithms/jaro_winkler_similarity.dart';
export 'src/algorithms/levenshtein_similarity.dart';

// Strategies (for custom ranking)
export 'src/ranking/adaptive_ranking_strategy.dart';

// Processors (for custom processing)
export 'src/processing/synchronous_processor.dart';
export 'src/processing/isolate_parallel_processor.dart';
