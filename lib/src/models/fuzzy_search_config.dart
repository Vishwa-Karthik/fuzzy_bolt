/// Configuration for fuzzy search operations.
class FuzzySearchConfig {
  /// Threshold for strict matching (higher means more exact).
  /// Values closer to 1.0 require more exact matches.
  final double strictThreshold;

  /// Threshold for typo tolerance (lower means more tolerant).
  /// Values closer to 0.0 allow more typos.
  final double typeThreshold;

  /// Minimum dataset size to trigger isolate usage for parallel processing.
  /// Set to a high value to disable isolates.
  final int isolateThreshold;

  /// Forces skipping isolate usage (required for web compatibility).
  final bool skipIsolate;

  /// Maximum number of results to return.
  final int? maxResults;

  const FuzzySearchConfig({
    this.strictThreshold = 0.85,
    this.typeThreshold = 0.65,
    this.isolateThreshold = 1000,
    this.skipIsolate = false,
    this.maxResults,
  }) : assert(
         strictThreshold >= 0.0 && strictThreshold <= 1.0,
         'strictThreshold must be between 0.0 and 1.0',
       ),
       assert(
         typeThreshold >= 0.0 && typeThreshold <= 1.0,
         'typeThreshold must be between 0.0 and 1.0',
       ),
       assert(isolateThreshold >= 0, 'isolateThreshold must be non-negative'),
       assert(
         maxResults == null || maxResults > 0,
         'maxResults must be positive if specified',
       );

  /// Creates a copy of this config with updated values.
  FuzzySearchConfig copyWith({
    double? strictThreshold,
    double? typeThreshold,
    int? isolateThreshold,
    bool? skipIsolate,
    int? maxResults,
  }) {
    return FuzzySearchConfig(
      strictThreshold: strictThreshold ?? this.strictThreshold,
      typeThreshold: typeThreshold ?? this.typeThreshold,
      isolateThreshold: isolateThreshold ?? this.isolateThreshold,
      skipIsolate: skipIsolate ?? this.skipIsolate,
      maxResults: maxResults ?? this.maxResults,
    );
  }
}
