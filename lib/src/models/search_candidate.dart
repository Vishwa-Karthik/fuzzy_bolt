/// Internal model representing a search candidate with its extracted text.
class SearchCandidate<T> {
  /// The original item from the dataset.
  final T item;

  /// The concatenated searchable text extracted from selectors.
  final String searchableText;

  /// The individual field texts for detailed matching.
  final List<String> fieldTexts;

  const SearchCandidate({
    required this.item,
    required this.searchableText,
    required this.fieldTexts,
  });

  @override
  String toString() {
    return 'SearchCandidate(searchableText: "$searchableText", fieldTexts: $fieldTexts)';
  }
}
