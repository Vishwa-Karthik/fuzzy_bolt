import '../interfaces/parallel_processor.dart';
import '../models/fuzzy_result.dart';
import '../models/search_candidate.dart';
import '../ranking/adaptive_ranking_strategy.dart';

/// Synchronous implementation of search processing.
///
/// This processor performs all search operations on the main thread
/// and is used as a fallback when isolates are not available or desired.
class SynchronousProcessor implements ParallelProcessor {
  const SynchronousProcessor();

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

    // Create a properly typed ranking strategy
    final rankingStrategy = AdaptiveRankingStrategy<T>();

    // Perform synchronous search
    final results = rankingStrategy.rankCandidates(
      candidates,
      query,
      strictThreshold,
      typeThreshold,
    );

    // Apply max results limit if specified
    if (maxResults != null && results.length > maxResults) {
      return results.take(maxResults).toList();
    }

    return results;
  }

  @override
  bool shouldUseParallelProcessing(
    int datasetSize,
    int threshold,
    bool skipIsolate,
  ) {
    // Synchronous processor never uses parallel processing
    return false;
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
}
