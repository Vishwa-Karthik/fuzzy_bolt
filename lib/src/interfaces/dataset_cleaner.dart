/// Interface for dataset cleaning strategies
abstract class DatasetCleanerStrategy<T> {
  /// Clean a dataset and return cleaned items with statistics
  CleaningResult<T> cleanDataset(
    List<T> items,
    List<String Function(T)> textSelectors, {
    double qualityThreshold = 0.3,
    bool removeDuplicates = true,
    bool removeOutliers = true,
  });

  /// Calculate quality score for a single item
  double calculateQualityScore(T item, List<String Function(T)> textSelectors);

  /// Check if two items are duplicates
  bool areDuplicates(T item1, T item2, List<String Function(T)> textSelectors);

  /// Get the name of this cleaning strategy
  String get strategyName;
}

/// Result of dataset cleaning operation
class CleaningResult<T> {
  final List<T> cleanedItems;
  final List<T> removedItems;
  final CleaningStatistics statistics;

  const CleaningResult({
    required this.cleanedItems,
    required this.removedItems,
    required this.statistics,
  });
}

/// Statistics from dataset cleaning
class CleaningStatistics {
  final int originalCount;
  final int cleanedCount;
  final int removedCount;
  final int duplicatesRemoved;
  final double qualityScore;
  final int processingTimeMs;

  const CleaningStatistics({
    required this.originalCount,
    required this.cleanedCount,
    required this.removedCount,
    required this.duplicatesRemoved,
    required this.qualityScore,
    required this.processingTimeMs,
  });

  @override
  String toString() {
    return 'CleaningStatistics('
        'original: $originalCount, '
        'cleaned: $cleanedCount, '
        'removed: $removedCount, '
        'duplicates: $duplicatesRemoved, '
        'quality: ${(qualityScore * 100).toStringAsFixed(1)}%, '
        'time: ${processingTimeMs}ms)';
  }
}
