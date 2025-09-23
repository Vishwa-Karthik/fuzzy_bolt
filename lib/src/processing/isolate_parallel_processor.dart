import 'dart:isolate';

import '../interfaces/parallel_processor.dart';
import '../models/fuzzy_result.dart';
import '../models/search_candidate.dart';
import '../ranking/adaptive_ranking_strategy.dart';

/// Implementation of parallel processing using Dart isolates.
///
/// This processor automatically switches to isolate-based processing
/// for large datasets to improve performance on multi-core systems.
class IsolateParallelProcessor implements ParallelProcessor {
  const IsolateParallelProcessor();

  @override
  Future<List<FuzzyResult<T>>> processSearch<T>({
    required List<T> dataset,
    required String query,
    required List<String Function(T)> selectors,
    required double strictThreshold,
    required double typeThreshold,
    required int? maxResults,
  }) async {
    // Convert dataset to search candidates
    final candidates = _createCandidates(dataset, selectors);

    // Use isolate for processing
    final searchData = _IsolateSearchData<T>(
      candidates: candidates,
      query: query,
      strictThreshold: strictThreshold,
      typeThreshold: typeThreshold,
      maxResults: maxResults,
    );

    try {
      final results = await Isolate.run(
        () => _performSearchInIsolate(searchData),
      );
      return results;
    } catch (e) {
      // Fallback to synchronous processing if isolate fails
      return _performSynchronousSearch(searchData);
    }
  }

  @override
  bool shouldUseParallelProcessing(
    int datasetSize,
    int threshold,
    bool skipIsolate,
  ) {
    // Skip isolates on web platform or if explicitly disabled
    if (skipIsolate) return false;

    // Check if running on web (no Platform class available or dart:html is imported)
    try {
      if (_isWeb()) return false;
    } catch (e) {
      // If we can't determine platform, assume non-web
    }

    return datasetSize >= threshold;
  }

  bool _isWeb() {
    // Simple check for web environment
    try {
      return identical(
        0,
        0.0,
      ); // This is false on web due to JS number handling
    } catch (e) {
      return false;
    }
  }

  List<SearchCandidate<T>> _createCandidates<T>(
    List<T> dataset,
    List<String Function(T)> selectors,
  ) {
    return dataset.map((item) {
      final fieldTexts = selectors.map((selector) => selector(item)).toList();
      final searchableText = fieldTexts.join(' ');

      return SearchCandidate<T>(
        item: item,
        searchableText: searchableText,
        fieldTexts: fieldTexts,
      );
    }).toList();
  }

  static List<FuzzyResult<T>> _performSearchInIsolate<T>(
    _IsolateSearchData<T> data,
  ) {
    return _performSynchronousSearch(data);
  }

  static List<FuzzyResult<T>> _performSynchronousSearch<T>(
    _IsolateSearchData<T> data,
  ) {
    final rankingStrategy = AdaptiveRankingStrategy<T>();

    final results = rankingStrategy.rankCandidates(
      data.candidates,
      data.query,
      data.strictThreshold,
      data.typeThreshold,
    );

    // Apply max results limit if specified
    final limitedResults =
        data.maxResults != null && results.length > data.maxResults!
            ? results.take(data.maxResults!).toList()
            : results;

    return limitedResults;
  }
}

/// Data class for passing search parameters to isolate.
class _IsolateSearchData<T> {
  final List<SearchCandidate<T>> candidates;
  final String query;
  final double strictThreshold;
  final double typeThreshold;
  final int? maxResults;

  const _IsolateSearchData({
    required this.candidates,
    required this.query,
    required this.strictThreshold,
    required this.typeThreshold,
    required this.maxResults,
  });
}
