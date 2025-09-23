import 'interfaces/parallel_processor.dart';
import 'models/fuzzy_result.dart';
import 'models/fuzzy_search_config.dart';
import 'processing/isolate_parallel_processor.dart';
import 'processing/synchronous_processor.dart';

/// Main fuzzy search engine class.
///
/// FuzzyBolt provides advanced fuzzy searching capabilities using
/// Jaro-Winkler and Levenshtein algorithms with adaptive ranking.
class FuzzyBolt {
  static const ParallelProcessor _isolateProcessor = IsolateParallelProcessor();
  static const ParallelProcessor _syncProcessor = SynchronousProcessor();

  /// Searches a dataset and returns matching items.
  ///
  /// [dataset] - The collection of items to search.
  /// [query] - The search query string.
  /// [selectors] - Functions to extract searchable text from items.
  /// [strictThreshold] - Minimum score for strict matches (default: 0.85).
  /// [typeThreshold] - Minimum score for typo-tolerant matches (default: 0.65).
  /// [isolateThreshold] - Minimum dataset size to use isolates (default: 1000).
  /// [skipIsolate] - Force disable isolate usage (default: false).
  /// [maxResults] - Maximum number of results to return.
  static Future<List<T>> search<T>(
    List<T> dataset,
    String query, {
    required List<String Function(T)> selectors,
    double strictThreshold = 0.85,
    double typeThreshold = 0.65,
    int isolateThreshold = 1000,
    bool skipIsolate = false,
    int? maxResults,
  }) async {
    final results = await searchWithScores<T>(
      dataset,
      query,
      selectors: selectors,
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: isolateThreshold,
      skipIsolate: skipIsolate,
      maxResults: maxResults,
    );

    return results.map((result) => result.item).toList();
  }

  /// Searches a dataset and returns matching items with their scores.
  ///
  /// [dataset] - The collection of items to search.
  /// [query] - The search query string.
  /// [selectors] - Functions to extract searchable text from items.
  /// [strictThreshold] - Minimum score for strict matches (default: 0.85).
  /// [typeThreshold] - Minimum score for typo-tolerant matches (default: 0.65).
  /// [isolateThreshold] - Minimum dataset size to use isolates (default: 1000).
  /// [skipIsolate] - Force disable isolate usage (default: false).
  /// [maxResults] - Maximum number of results to return.
  static Future<List<FuzzyResult<T>>> searchWithScores<T>(
    List<T> dataset,
    String query, {
    required List<String Function(T)> selectors,
    double strictThreshold = 0.85,
    double typeThreshold = 0.65,
    int isolateThreshold = 1000,
    bool skipIsolate = false,
    int? maxResults,
  }) async {
    // Validate inputs
    if (dataset.isEmpty || query.trim().isEmpty || selectors.isEmpty) {
      return <FuzzyResult<T>>[];
    }

    final config = FuzzySearchConfig(
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: isolateThreshold,
      skipIsolate: skipIsolate,
      maxResults: maxResults,
    );

    return _performSearch<T>(dataset, query, selectors, config);
  }

  /// Searches with a configuration object.
  ///
  /// [dataset] - The collection of items to search.
  /// [query] - The search query string.
  /// [selectors] - Functions to extract searchable text from items.
  /// [config] - Search configuration.
  static Future<List<FuzzyResult<T>>> searchWithConfig<T>(
    List<T> dataset,
    String query,
    List<String Function(T)> selectors,
    FuzzySearchConfig config,
  ) async {
    if (dataset.isEmpty || query.trim().isEmpty || selectors.isEmpty) {
      return <FuzzyResult<T>>[];
    }

    return _performSearch<T>(dataset, query, selectors, config);
  }

  static Future<List<FuzzyResult<T>>> _performSearch<T>(
    List<T> dataset,
    String query,
    List<String Function(T)> selectors,
    FuzzySearchConfig config,
  ) async {
    final normalizedQuery = query.trim();

    // Choose processor based on dataset size and configuration
    final processor = _selectProcessor(dataset.length, config);

    try {
      return await processor.processSearch<T>(
        dataset: dataset,
        query: normalizedQuery,
        selectors: selectors,
        strictThreshold: config.strictThreshold,
        typeThreshold: config.typeThreshold,
        maxResults: config.maxResults,
      );
    } catch (e) {
      // Fallback to synchronous processing on any error
      return await _syncProcessor.processSearch<T>(
        dataset: dataset,
        query: normalizedQuery,
        selectors: selectors,
        strictThreshold: config.strictThreshold,
        typeThreshold: config.typeThreshold,
        maxResults: config.maxResults,
      );
    }
  }

  static ParallelProcessor _selectProcessor(
    int datasetSize,
    FuzzySearchConfig config,
  ) {
    if (_isolateProcessor.shouldUseParallelProcessing(
      datasetSize,
      config.isolateThreshold,
      config.skipIsolate,
    )) {
      return _isolateProcessor;
    }
    return _syncProcessor;
  }
}
