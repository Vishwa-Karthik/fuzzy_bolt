import '../models/fuzzy_result.dart';

/// Interface for parallel processing of search operations.
abstract class ParallelProcessor {
  /// Processes search operations in parallel when dataset size exceeds threshold.
  Future<List<FuzzyResult<T>>> processSearch<T>({
    required List<T> dataset,
    required String query,
    required List<String Function(T)> selectors,
    required double strictThreshold,
    required double typeThreshold,
    required int? maxResults,
  });

  /// Checks if parallel processing should be used based on dataset size and platform.
  bool shouldUseParallelProcessing(
    int datasetSize,
    int threshold,
    bool skipIsolate,
  );
}
