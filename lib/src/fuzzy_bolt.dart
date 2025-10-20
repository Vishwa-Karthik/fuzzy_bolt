import 'interfaces/parallel_processor.dart';
import 'models/fuzzy_result.dart';
import 'models/fuzzy_search_config.dart';
import 'algorithms/porter_stemmer.dart';
import 'algorithms/dataset_cleaner.dart';
import 'processing/isolate_parallel_processor.dart';
import 'processing/synchronous_processor.dart';

/// Main fuzzy search engine class.
///
/// FuzzyBolt provides advanced fuzzy searching capabilities using
/// Jaro-Winkler and Levenshtein algorithms with adaptive ranking,
/// text processing (stemming), and dataset cleaning.
class FuzzyBolt {
  static const ParallelProcessor _isolateProcessor = IsolateParallelProcessor();
  static const ParallelProcessor _syncProcessor = SynchronousProcessor();

  // Enhanced features - text processing and dataset cleaning
  static final Map<String, String> _textCache = <String, String>{};
  static const int _maxCacheSize = 1000;
  static const int _maxStringLength =
      50000; // Prevent DoS with very long strings

  /// Validates input parameters and throws descriptive errors
  static void _validateInputs({
    required double strictThreshold,
    required double typeThreshold,
    required int isolateThreshold,
    int? maxResults,
  }) {
    if (strictThreshold < 0.0 || strictThreshold > 1.0) {
      throw ArgumentError(
        'strictThreshold must be between 0.0 and 1.0, got: $strictThreshold',
      );
    }
    if (typeThreshold < 0.0 || typeThreshold > 1.0) {
      throw ArgumentError(
        'typeThreshold must be between 0.0 and 1.0, got: $typeThreshold',
      );
    }
    if (isolateThreshold < 0) {
      throw ArgumentError(
        'isolateThreshold must be non-negative, got: $isolateThreshold',
      );
    }
    if (maxResults != null && maxResults <= 0) {
      throw ArgumentError(
        'maxResults must be positive if specified, got: $maxResults',
      );
    }
  }

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
  /// [enableStemming] - Whether to apply Porter stemming (default: false).
  /// [enableCleaning] - Whether to clean dataset for better results (default: false).
  static Future<List<T>> search<T>(
    List<T> dataset,
    String query, {
    required List<String Function(T)> selectors,
    double strictThreshold = 0.85,
    double typeThreshold = 0.65,
    int isolateThreshold = 1000,
    bool skipIsolate = false,
    int? maxResults,
    bool enableStemming = false,
    bool enableCleaning = false,
  }) async {
    // Validate inputs early
    _validateInputs(
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: isolateThreshold,
      maxResults: maxResults,
    );
    final results = await searchWithScores<T>(
      dataset,
      query,
      selectors: selectors,
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: isolateThreshold,
      skipIsolate: skipIsolate,
      maxResults: maxResults,
      enableStemming: enableStemming,
      enableCleaning: enableCleaning,
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
  /// [enableStemming] - Whether to apply Porter stemming (default: false).
  /// [enableCleaning] - Whether to clean dataset for better results (default: false).
  static Future<List<FuzzyResult<T>>> searchWithScores<T>(
    List<T> dataset,
    String query, {
    required List<String Function(T)> selectors,
    double strictThreshold = 0.85,
    double typeThreshold = 0.65,
    int isolateThreshold = 1000,
    bool skipIsolate = false,
    int? maxResults,
    bool enableStemming = false,
    bool enableCleaning = false,
  }) async {
    // Validate inputs early
    _validateInputs(
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: isolateThreshold,
      maxResults: maxResults,
    );

    // Validate basic inputs
    if (dataset.isEmpty || query.trim().isEmpty || selectors.isEmpty) {
      return <FuzzyResult<T>>[];
    }

    // Prevent DoS with very long query strings
    if (query.length > _maxStringLength) {
      throw ArgumentError(
        'Query string too long. Maximum length is $_maxStringLength characters.',
      );
    }

    // Apply enhanced features if enabled
    if (enableStemming || enableCleaning) {
      // Step 1: Clean dataset if enabled
      List<T> searchDataset = dataset;

      if (enableCleaning) {
        final cleaner = StandardDatasetCleaner.forEcommerce<dynamic>();
        final cleaningResult = cleaner.cleanDataset(
          dataset,
          selectors.map((s) => (dynamic item) => s(item as T)).toList(),
          qualityThreshold: 0.3,
          removeDuplicates: true,
          removeOutliers: true,
        );
        searchDataset = cleaningResult.cleanedItems.cast<T>();
      }

      // Step 2: Process text if enabled
      String processedQuery = query;
      List<String Function(T)> processedSelectors = selectors;

      if (enableStemming) {
        processedQuery = _processText(
          query,
          enableStemming: true,
          removeStopWords: false,
        );

        processedSelectors =
            selectors.map((selector) {
              return (T item) => _processText(
                selector(item),
                enableStemming: true,
                removeStopWords: false,
              );
            }).toList();
      }

      // Step 3: Perform basic search
      final config = FuzzySearchConfig(
        strictThreshold: strictThreshold,
        typeThreshold: typeThreshold,
        isolateThreshold: isolateThreshold,
        skipIsolate: skipIsolate,
        maxResults: maxResults,
      );

      return _performSearch<T>(
        searchDataset,
        processedQuery,
        processedSelectors,
        config,
      );
    }

    // Fallback to basic search if both features are disabled
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
    // Note: Config validation is handled by FuzzySearchConfig constructor

    if (dataset.isEmpty || query.trim().isEmpty || selectors.isEmpty) {
      return <FuzzyResult<T>>[];
    }

    // Prevent DoS with very long query strings
    if (query.length > _maxStringLength) {
      throw ArgumentError(
        'Query string too long. Maximum length is $_maxStringLength characters.',
      );
    }

    return _performSearch<T>(dataset, query, selectors, config);
  }

  /// Search with automatic text processing (stemming, normalization).
  ///
  /// [dataset] - The collection of items to search.
  /// [query] - The search query string.
  /// [selectors] - Functions to extract searchable text from items.
  /// [enableStemming] - Whether to apply Porter stemming algorithm.
  /// [removeStopWords] - Whether to remove common stop words.
  /// [customStopWords] - Additional stop words to remove.
  /// [strictThreshold] - Minimum score for strict matches.
  /// [typeThreshold] - Minimum score for typo-tolerant matches.
  /// [maxResults] - Maximum number of results to return.
  static Future<List<FuzzyResult<T>>> searchWithTextProcessing<T>(
    List<T> dataset,
    String query, {
    required List<String Function(T)> selectors,
    bool enableStemming = true,
    bool removeStopWords = false,
    Set<String> customStopWords = const {},
    double strictThreshold = 0.85,
    double typeThreshold = 0.65,
    int? maxResults,
  }) async {
    // Validate inputs early
    _validateInputs(
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: 1000,
      maxResults: maxResults,
    );

    if (dataset.isEmpty || query.trim().isEmpty || selectors.isEmpty) {
      return <FuzzyResult<T>>[];
    }

    // Prevent DoS with very long query strings
    if (query.length > _maxStringLength) {
      throw ArgumentError(
        'Query string too long. Maximum length is $_maxStringLength characters.',
      );
    }

    // Process the query
    final processedQuery = _processText(
      query,
      enableStemming: enableStemming,
      removeStopWords: removeStopWords,
      customStopWords: customStopWords,
    );

    // Create processed selectors
    final processedSelectors =
        selectors.map((selector) {
          return (T item) => _processText(
            selector(item),
            enableStemming: enableStemming,
            removeStopWords: removeStopWords,
            customStopWords: customStopWords,
          );
        }).toList();

    // Perform regular search with processed text
    final config = FuzzySearchConfig(
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      isolateThreshold: 1000,
      skipIsolate: false,
      maxResults: maxResults,
    );

    return _performSearch<T>(
      dataset,
      processedQuery,
      processedSelectors,
      config,
    );
  }

  /// Search with dataset cleaning to improve result quality.
  ///
  /// [dataset] - The collection of items to search.
  /// [query] - The search query string.
  /// [selectors] - Functions to extract searchable text from items.
  /// [qualityThreshold] - Minimum quality score for items (0.0 to 1.0).
  /// [removeDuplicates] - Whether to remove duplicate items.
  /// [removeOutliers] - Whether to remove statistical outliers.
  static Future<List<FuzzyResult<T>>> _performSearch<T>(
    List<T> dataset,
    String query,
    List<String Function(T)> selectors,
    FuzzySearchConfig config,
  ) async {
    final normalizedQuery = query.trim();

    // Validate selectors by testing them safely
    try {
      if (dataset.isNotEmpty) {
        for (final selector in selectors) {
          final testResult = selector(dataset.first);
          if (testResult.length > _maxStringLength) {
            // Log warning but don't fail - truncation will handle it
          }
        }
      }
    } catch (e) {
      throw ArgumentError('One or more selectors threw an exception: $e');
    }

    // Choose processor based on dataset size and configuration
    final processor = _selectProcessor(dataset.length, config);

    try {
      // Add timeout protection for long-running operations
      return await processor
          .processSearch<T>(
            dataset: dataset,
            query: normalizedQuery,
            selectors: selectors,
            strictThreshold: config.strictThreshold,
            typeThreshold: config.typeThreshold,
            maxResults: config.maxResults,
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              // Fallback to synchronous processing on timeout
              return _syncProcessor.processSearch<T>(
                dataset: dataset,
                query: normalizedQuery,
                selectors: selectors,
                strictThreshold: config.strictThreshold,
                typeThreshold: config.typeThreshold,
                maxResults: config.maxResults,
              );
            },
          );
    } catch (e) {
      // Fallback to synchronous processing on any error
      try {
        return await _syncProcessor.processSearch<T>(
          dataset: dataset,
          query: normalizedQuery,
          selectors: selectors,
          strictThreshold: config.strictThreshold,
          typeThreshold: config.typeThreshold,
          maxResults: config.maxResults,
        );
      } catch (fallbackError) {
        // If even synchronous processing fails, return empty results
        return <FuzzyResult<T>>[];
      }
    }
  }

  /// Process text according to the given configuration
  static String _processText(
    String text, {
    bool enableStemming = false,
    bool removeStopWords = false,
    Set<String> customStopWords = const {},
  }) {
    if (text.isEmpty) return text;

    // Prevent DoS with very long selector strings
    if (text.length > _maxStringLength) {
      // Truncate very long strings instead of throwing error
      text = text.substring(0, _maxStringLength);
    }

    // Check cache first
    final cacheKey =
        '$text|$enableStemming|$removeStopWords|${customStopWords.join(",")}';
    if (_textCache.containsKey(cacheKey)) {
      return _textCache[cacheKey]!;
    }

    String processed = text.toLowerCase().trim();

    // Remove stop words if enabled
    if (removeStopWords) {
      final stopWords = {...PorterStemmer.stopWords, ...customStopWords};
      final words = processed.split(RegExp(r'\s+'));
      final filteredWords = words.where(
        (word) => word.isNotEmpty && !stopWords.contains(word.toLowerCase()),
      );
      processed = filteredWords.join(' ');
    }

    // Apply stemming if enabled
    if (enableStemming) {
      processed = PorterStemmer.stemText(processed);
    }

    // Normalize whitespace
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Cache result if cache isn't full
    if (_textCache.length < _maxCacheSize) {
      _textCache[cacheKey] = processed;
    }

    return processed;
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

  /// Clear the text processing cache
  static void clearTextCache() {
    _textCache.clear();
  }

  /// Get text cache statistics
  static Map<String, dynamic> getTextCacheStats() {
    return {
      'cacheSize': _textCache.length,
      'maxCacheSize': _maxCacheSize,
      'utilization':
          _maxCacheSize > 0 ? _textCache.length / _maxCacheSize : 0.0,
    };
  }
}
