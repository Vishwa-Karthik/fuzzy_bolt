/// Represents a fuzzy search result with the matched item, score, and matched text.
class FuzzyResult<T> {
  /// The original item from the dataset.
  final T item;

  /// The similarity score between 0.0 and 1.0.
  /// Higher scores indicate better matches.
  final double score;

  /// The normalized text that was matched against the query.
  final String matchedText;

  const FuzzyResult({
    required this.item,
    required this.score,
    required this.matchedText,
  });

  @override
  String toString() {
    return 'FuzzyResult(score: $score, matchedText: "$matchedText", item: $item)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FuzzyResult<T> &&
        other.item == item &&
        other.score == score &&
        other.matchedText == matchedText;
  }

  @override
  int get hashCode => Object.hash(item, score, matchedText);
}
