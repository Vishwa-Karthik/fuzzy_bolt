import '../interfaces/dataset_cleaner.dart';
import 'porter_stemmer.dart';

/// Advanced dataset cleaning implementation for improving search quality
class StandardDatasetCleaner<T> implements DatasetCleanerStrategy<T> {
  final double _qualityThreshold;
  final bool _removeDuplicates;
  final bool _removeOutliers;
  final bool _enableStemming;
  final int _minTextLength;
  final double _similarityThreshold;

  const StandardDatasetCleaner({
    double qualityThreshold = 0.3,
    bool removeDuplicates = true,
    bool removeOutliers = true,
    bool enableStemming = false,
    int minTextLength = 2,
    double similarityThreshold = 0.85,
  }) : _qualityThreshold = qualityThreshold,
       _removeDuplicates = removeDuplicates,
       _removeOutliers = removeOutliers,
       _enableStemming = enableStemming,
       _minTextLength = minTextLength,
       _similarityThreshold = similarityThreshold;

  @override
  String get strategyName => 'Standard Dataset Cleaner';

  @override
  CleaningResult<T> cleanDataset(
    List<T> items,
    List<String Function(T)> textSelectors, {
    double qualityThreshold = 0.3,
    bool removeDuplicates = true,
    bool removeOutliers = true,
  }) {
    final stopwatch = Stopwatch()..start();
    final originalCount = items.length;

    if (items.isEmpty) {
      return CleaningResult(
        cleanedItems: [],
        removedItems: [],
        statistics: CleaningStatistics(
          originalCount: 0,
          cleanedCount: 0,
          removedCount: 0,
          duplicatesRemoved: 0,
          qualityScore: 1.0,
          processingTimeMs: stopwatch.elapsedMilliseconds,
        ),
      );
    }

    final List<T> cleaned = List.from(items);
    final List<T> removed = <T>[];
    int duplicatesRemoved = 0;

    // Step 1: Remove items with poor quality scores
    final qualityFiltered = <T>[];
    for (final item in cleaned) {
      final quality = calculateQualityScore(item, textSelectors);
      if (quality >=
          (qualityThreshold > 0 ? qualityThreshold : _qualityThreshold)) {
        qualityFiltered.add(item);
      } else {
        removed.add(item);
      }
    }

    // Step 2: Remove duplicates if enabled
    final List<T> deduplicatedItems;
    if (removeDuplicates && _removeDuplicates) {
      deduplicatedItems = <T>[];
      final seenItems = <T>[];

      for (final item in qualityFiltered) {
        bool isDuplicate = false;
        for (final seenItem in seenItems) {
          if (areDuplicates(item, seenItem, textSelectors)) {
            removed.add(item);
            duplicatesRemoved++;
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          deduplicatedItems.add(item);
          seenItems.add(item);
        }
      }
    } else {
      deduplicatedItems = qualityFiltered;
    }

    // Step 3: Remove outliers if enabled
    final List<T> finalItems;
    if (removeOutliers && _removeOutliers && deduplicatedItems.length > 3) {
      finalItems = _removeOutlierItems(
        deduplicatedItems,
        textSelectors,
        removed,
      );
    } else {
      finalItems = deduplicatedItems;
    }

    stopwatch.stop();

    // Calculate overall quality score
    final qualityScores =
        finalItems
            .map((item) => calculateQualityScore(item, textSelectors))
            .toList();
    final averageQuality =
        qualityScores.isEmpty
            ? 0.0
            : qualityScores.reduce((a, b) => a + b) / qualityScores.length;

    return CleaningResult(
      cleanedItems: finalItems,
      removedItems: removed,
      statistics: CleaningStatistics(
        originalCount: originalCount,
        cleanedCount: finalItems.length,
        removedCount: removed.length,
        duplicatesRemoved: duplicatesRemoved,
        qualityScore: averageQuality,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      ),
    );
  }

  @override
  double calculateQualityScore(T item, List<String Function(T)> textSelectors) {
    double totalScore = 0.0;
    int validSelectors = 0;

    for (final selector in textSelectors) {
      final text = selector(item);
      final score = _calculateTextQuality(text);
      if (score > 0) {
        totalScore += score;
        validSelectors++;
      }
    }

    return validSelectors > 0 ? totalScore / validSelectors : 0.0;
  }

  @override
  bool areDuplicates(T item1, T item2, List<String Function(T)> textSelectors) {
    for (final selector in textSelectors) {
      final text1 = _normalizeText(selector(item1));
      final text2 = _normalizeText(selector(item2));

      if (text1.isEmpty || text2.isEmpty) continue;

      // Exact match after normalization
      if (text1 == text2) return true;

      // High similarity match
      final similarity = _calculateSimilarity(text1, text2);
      if (similarity >= _similarityThreshold) return true;
    }

    return false;
  }

  /// Calculate quality score for a text string
  double _calculateTextQuality(String text) {
    if (text.isEmpty) return 0.0;

    double score = 1.0;

    // Penalize very short text
    if (text.length < _minTextLength) {
      score *= 0.1;
    } else if (text.length < 5) {
      score *= 0.5;
    }

    // Penalize texts with too many numbers
    final numberCount = text.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (numberCount > text.length * 0.7) {
      score *= 0.3;
    }

    // Penalize texts with too many special characters
    final specialCharCount =
        text.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '').length;
    if (specialCharCount > text.length * 0.3) {
      score *= 0.5;
    }

    // Penalize repetitive content (same character repeated)
    final uniqueChars = text.toLowerCase().split('').toSet().length;
    if (uniqueChars < 3 && text.length > 5) {
      score *= 0.2;
    }

    // Reward reasonable length
    if (text.length >= 10 && text.length <= 200) {
      score *= 1.2;
    }

    // Reward texts with good word count
    final words = text.split(RegExp(r'\s+'));
    if (words.length >= 2 && words.length <= 50) {
      score *= 1.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Remove outlier items based on text characteristics
  List<T> _removeOutlierItems(
    List<T> items,
    List<String Function(T)> textSelectors,
    List<T> removed,
  ) {
    if (items.length <= 3) return items;

    // Calculate quality scores for all items
    final itemScores =
        items.map((item) {
          return MapEntry(item, calculateQualityScore(item, textSelectors));
        }).toList();

    // Sort by quality score
    itemScores.sort((a, b) => b.value.compareTo(a.value));

    // Calculate statistics
    final scores = itemScores.map((e) => e.value).toList();
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores
            .map((score) => (score - mean) * (score - mean))
            .reduce((a, b) => a + b) /
        scores.length;
    final stdDev = variance > 0 ? variance.sqrt() : 0.0;

    // Remove items that are more than 2 standard deviations below the mean
    final threshold = mean - (2 * stdDev);

    final filteredItems = <T>[];
    for (final entry in itemScores) {
      if (entry.value >= threshold || entry.value >= _qualityThreshold) {
        filteredItems.add(entry.key);
      } else {
        removed.add(entry.key);
      }
    }

    return filteredItems;
  }

  /// Normalize text for comparison
  String _normalizeText(String text) {
    String normalized = text.toLowerCase().trim();

    if (_enableStemming) {
      normalized = PorterStemmer.stemText(normalized);
    }

    // Remove extra whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove common punctuation
    normalized = normalized.replaceAll(RegExp(r'[.,!?;:"()[\]{}]'), '');

    return normalized;
  }

  /// Calculate simple similarity between two texts
  double _calculateSimilarity(String text1, String text2) {
    if (text1 == text2) return 1.0;
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    // Simple character-based similarity
    final maxLength = text1.length > text2.length ? text1.length : text2.length;
    if (maxLength == 0) return 1.0;

    int differences = 0;
    final minLength = text1.length < text2.length ? text1.length : text2.length;

    for (int i = 0; i < minLength; i++) {
      if (text1[i] != text2[i]) {
        differences++;
      }
    }

    differences += (maxLength - minLength);

    return 1.0 - (differences / maxLength);
  }

  /// Factory methods for common use cases

  /// Create a minimal cleaner for basic quality filtering
  static StandardDatasetCleaner<T> minimal<T>() {
    return StandardDatasetCleaner<T>(
      qualityThreshold: 0.1,
      removeDuplicates: false,
      removeOutliers: false,
      enableStemming: false,
    );
  }

  /// Create a cleaner optimized for e-commerce data
  static StandardDatasetCleaner<T> forEcommerce<T>() {
    return StandardDatasetCleaner<T>(
      qualityThreshold: 0.4,
      removeDuplicates: true,
      removeOutliers: true,
      enableStemming: true,
      minTextLength: 3,
      similarityThreshold: 0.9,
    );
  }

  /// Create an aggressive cleaner for maximum quality
  static StandardDatasetCleaner<T> aggressive<T>() {
    return StandardDatasetCleaner<T>(
      qualityThreshold: 0.6,
      removeDuplicates: true,
      removeOutliers: true,
      enableStemming: true,
      minTextLength: 5,
      similarityThreshold: 0.8,
    );
  }
}

/// Extension to add sqrt method to double
extension DoubleExtensions on double {
  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;

    double x = this;
    double prev;

    // Newton's method for square root
    do {
      prev = x;
      x = (x + this / x) / 2;
    } while ((x - prev).abs() > 0.0001);

    return x;
  }
}
