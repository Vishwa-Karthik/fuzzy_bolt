/// Interface for text processing algorithms like stemming, lemmatization, etc.
abstract class TextProcessor {
  /// Process a single word and return the processed form
  String processWord(String word);

  /// Process a complete text string
  String processText(String text);

  /// Get the name/type of this processor
  String get processorName;

  /// Check if this processor supports the given language
  bool supportsLanguage(String languageCode);

  /// Reset any internal state (like caches)
  void reset();

  /// Get statistics about processing (cache hits, processing time, etc.)
  Map<String, dynamic> getStatistics();
}
