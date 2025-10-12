import 'package:fuzzy_bolt/fuzzy_bolt.dart';

/// Comprehensive FuzzyBolt API demonstration
/// Shows all available search methods and features
void main() async {
  print('🎯 FuzzyBolt - Complete API Demonstration\n');
  print('=========================================\n');

  await _basicSearchDemo();
  await _searchWithScoresDemo();
  await _searchWithConfigDemo();
  await _textProcessingDemo();
  await _stemmingDemo();
  await _datasetCleaningDemo();
  await _performanceDemo();
  await _cacheManagementDemo();

  print('\n✅ All API demonstrations completed successfully!');
}

// ============================================================================
// 1. BASIC SEARCH API - FuzzyBolt.search()
// Returns matching items without scores
// ============================================================================
Future<void> _basicSearchDemo() async {
  print('1️⃣ BASIC SEARCH API - FuzzyBolt.search()');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final products = [
    const Product(
      id: 1,
      name: 'Running Shoes',
      category: 'Sports',
      price: 89.99,
    ),
    const Product(
      id: 2,
      name: 'Basketball Sneakers',
      category: 'Sports',
      price: 109.99,
    ),
    const Product(
      id: 3,
      name: 'Walking Boots',
      category: 'Outdoor',
      price: 129.99,
    ),
    const Product(
      id: 4,
      name: 'Athletic Footwear',
      category: 'Sports',
      price: 79.99,
    ),
  ];

  print('\n📦 Dataset: ${products.length} products');

  // Example 1: Simple search
  print('\n🔍 Example 1: Simple search for "running"');
  final results1 = await FuzzyBolt.search<Product>(
    products,
    'running',
    selectors: [(p) => p.name],
  );
  print('   Results: ${results1.map((p) => p.name).join(", ")}');

  // Example 2: Search with typo tolerance
  print('\n🔍 Example 2: Search with typo "runing" (missing n)');
  final results2 = await FuzzyBolt.search<Product>(
    products,
    'runing',
    selectors: [(p) => p.name],
    typeThreshold: 0.7,
  );
  print('   Results: ${results2.map((p) => p.name).join(", ")}');

  // Example 3: Multi-field search
  print('\n🔍 Example 3: Search "sport" across name and category');
  final results3 = await FuzzyBolt.search<Product>(
    products,
    'sport',
    selectors: [(p) => p.name, (p) => p.category],
    typeThreshold: 0.6,
  );
  print('   Results: ${results3.map((p) => p.name).join(", ")}');

  // Example 4: Limit results
  print('\n🔍 Example 4: Search with maxResults=2');
  final results4 = await FuzzyBolt.search<Product>(
    products,
    'shoes',
    selectors: [(p) => p.name],
    maxResults: 2,
  );
  print('   Results: ${results4.map((p) => p.name).join(", ")}');

  // Example 5: With stemming enabled (default)
  print('\n🔍 Example 5: Search "running" with stemming enabled');
  final results5 = await FuzzyBolt.search<Product>(
    products,
    'running',
    selectors: [(p) => p.name],
    enableStemming: true, // Default is true
  );
  print('   Results: ${results5.map((p) => p.name).join(", ")}');

  print('\n');
}

// ============================================================================
// 2. SEARCH WITH SCORES API - FuzzyBolt.searchWithScores()
// Returns results with match confidence scores
// ============================================================================
Future<void> _searchWithScoresDemo() async {
  print('2️⃣ SEARCH WITH SCORES API - FuzzyBolt.searchWithScores()');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final users = [
    const User(
      id: 1,
      name: 'Alice Johnson',
      email: 'alice@company.com',
      dept: 'Engineering',
    ),
    const User(
      id: 2,
      name: 'Bob Smith',
      email: 'bob@company.com',
      dept: 'Marketing',
    ),
    const User(
      id: 3,
      name: 'Charlie Brown',
      email: 'charlie@company.com',
      dept: 'Sales',
    ),
    const User(
      id: 4,
      name: 'Diana Prince',
      email: 'diana@company.com',
      dept: 'Engineering',
    ),
    const User(id: 5, name: 'Eve Adams', email: 'eve@company.com', dept: 'HR'),
  ];

  print('\n👥 Dataset: ${users.length} users');

  // Example 1: Get scores for ranking
  print('\n🔍 Example 1: Search "Alice" with scores');
  final results1 = await FuzzyBolt.searchWithScores<User>(
    users,
    'Alice',
    selectors: [(u) => u.name],
  );
  for (final result in results1) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.name} - $score% match');
  }

  // Example 2: Typo with confidence scores
  print('\n🔍 Example 2: Search "Alise" (typo) with scores');
  final results2 = await FuzzyBolt.searchWithScores<User>(
    users,
    'Alise',
    selectors: [(u) => u.name],
    typeThreshold: 0.65,
  );
  for (final result in results2) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.name} - $score% match');
  }

  // Example 3: Multi-field with scores
  print('\n🔍 Example 3: Search "eng" across name and department');
  final results3 = await FuzzyBolt.searchWithScores<User>(
    users,
    'eng',
    selectors: [(u) => u.name, (u) => u.dept],
    typeThreshold: 0.5,
  );
  for (final result in results3) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.name} (${result.item.dept}) - $score% match');
  }

  // Example 4: With stemming and cleaning enabled
  print('\n🔍 Example 4: Search with stemming + cleaning enabled');
  final results4 = await FuzzyBolt.searchWithScores<User>(
    users,
    'engineer',
    selectors: [(u) => u.dept],
    enableStemming: true, // Stems "engineer" -> "engin"
    enableCleaning: true, // Removes duplicates
    typeThreshold: 0.5,
  );
  for (final result in results4) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.name} (${result.item.dept}) - $score% match');
  }

  // Example 5: Email search with strict threshold
  print('\n🔍 Example 5: Email search with strict threshold');
  final results5 = await FuzzyBolt.searchWithScores<User>(
    users,
    'alice@company',
    selectors: [(u) => u.email],
    strictThreshold: 0.85,
  );
  for (final result in results5) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.email} - $score% match');
  }

  print('\n');
}

// ============================================================================
// 3. SEARCH WITH CONFIG API - FuzzyBolt.searchWithConfig()
// Use FuzzySearchConfig for fine-grained control
// ============================================================================
Future<void> _searchWithConfigDemo() async {
  print('3️⃣ SEARCH WITH CONFIG API - FuzzyBolt.searchWithConfig()');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final documents = List.generate(
    20,
    (i) => Document(
      id: i,
      title: 'Document ${i + 1}',
      content:
          'Content about ${["AI", "ML", "Data", "Cloud", "Security"][i % 5]}',
    ),
  );

  print('\n📄 Dataset: ${documents.length} documents');

  // Example 1: High precision config
  print('\n🔍 Example 1: High precision configuration');
  final strictConfig = FuzzySearchConfig(
    strictThreshold: 0.95, // Very strict
    typeThreshold: 0.85, // Less typo tolerance
    maxResults: 5,
    skipIsolate: true, // Force synchronous
  );

  final results1 = await FuzzyBolt.searchWithConfig<Document>(
    documents,
    'Document 5',
    [(d) => d.title],
    strictConfig,
  );
  print('   Results: ${results1.length} found');
  for (final result in results1.take(3)) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.title} - $score%');
  }

  // Example 2: Fuzzy/lenient config
  print('\n🔍 Example 2: Lenient configuration (more typo tolerance)');
  final lenientConfig = FuzzySearchConfig(
    strictThreshold: 0.7,
    typeThreshold: 0.5, // Very lenient
    maxResults: 10,
  );

  final results2 = await FuzzyBolt.searchWithConfig<Document>(
    documents,
    'secrity', // typo in "security"
    [(d) => d.content],
    lenientConfig,
  );
  print('   Results: ${results2.length} found');
  for (final result in results2.take(3)) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.content} - $score%');
  }

  // Example 3: Performance config for large datasets
  print('\n🔍 Example 3: Performance config (isolate threshold)');
  final perfConfig = FuzzySearchConfig(
    strictThreshold: 0.8,
    typeThreshold: 0.65,
    isolateThreshold: 10, // Use isolates for 10+ items
    maxResults: 5,
  );

  final results3 = await FuzzyBolt.searchWithConfig<Document>(
    documents,
    'cloud data',
    [(d) => d.content],
    perfConfig,
  );
  print('   Results: ${results3.length} found (used isolates)');

  print('\n');
}

// ============================================================================
// 4. TEXT PROCESSING API - FuzzyBolt.searchWithTextProcessing()
// Advanced text processing with stemming and stop word removal
// ============================================================================
Future<void> _textProcessingDemo() async {
  print('4️⃣ TEXT PROCESSING API - FuzzyBolt.searchWithTextProcessing()');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final articles = [
    const Article(
      id: 1,
      title: 'The runners were running quickly through the forest',
      tags: 'running, athletics, sports, outdoor',
    ),
    const Article(
      id: 2,
      title: 'Professional athletes training for marathon running',
      tags: 'marathon, training, professional, running',
    ),
    const Article(
      id: 3,
      title: 'Walking and jogging in the park daily',
      tags: 'walking, jogging, exercise, park',
    ),
  ];

  print('\n📰 Dataset: ${articles.length} articles');

  // Example 1: Basic text processing with stemming
  print('\n🔍 Example 1: Search with stemming enabled');
  print('   Query: "running" → stems to "run"');
  final results1 = await FuzzyBolt.searchWithTextProcessing<Article>(
    articles,
    'running',
    selectors: [(a) => a.title, (a) => a.tags],
    enableStemming: true,
  );
  for (final result in results1) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.title.substring(0, 50)}... - $score%');
  }

  // Example 2: With stop word removal
  print('\n🔍 Example 2: Search with stop word removal');
  print('   Query: "the runners were running" → "runners running"');
  final results2 = await FuzzyBolt.searchWithTextProcessing<Article>(
    articles,
    'the runners were running',
    selectors: [(a) => a.title],
    enableStemming: true,
    removeStopWords: true, // Removes "the", "were"
  );
  for (final result in results2) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.title.substring(0, 50)}... - $score%');
  }

  // Example 3: Custom stop words
  print('\n🔍 Example 3: Search with custom stop words');
  final results3 = await FuzzyBolt.searchWithTextProcessing<Article>(
    articles,
    'professional athletes training',
    selectors: [(a) => a.title],
    enableStemming: true,
    removeStopWords: true,
    customStopWords: {'for', 'the', 'and', 'in'}, // Custom set
  );
  for (final result in results3) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.title.substring(0, 50)}... - $score%');
  }

  // Example 4: Stemming only (no stop word removal)
  print('\n🔍 Example 4: Stemming only, no stop word removal');
  final results4 = await FuzzyBolt.searchWithTextProcessing<Article>(
    articles,
    'runners running quickly',
    selectors: [(a) => a.title],
    enableStemming: true,
    removeStopWords: false,
  );
  for (final result in results4) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.title.substring(0, 50)}... - $score%');
  }

  print('\n');
}

// ============================================================================
// 5. PORTER STEMMER API
// Direct access to Porter Stemming algorithm
// ============================================================================
Future<void> _stemmingDemo() async {
  print('5️⃣ PORTER STEMMER API - PorterStemmer');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  print('\n📝 Individual word stemming:');

  final words = [
    'running',
    'runner',
    'runs',
    'ran',
    'quickly',
    'walking',
    'walked',
    'flies',
    'flying',
    'dogs',
    'cats',
  ];

  for (final word in words) {
    final stemmed = PorterStemmer.stem(word);
    print('   $word → $stemmed');
  }

  print('\n📝 Full text stemming:');

  final texts = [
    'The runners were running quickly',
    'Professional athletes training daily',
    'Dogs and cats playing together',
  ];

  for (final text in texts) {
    final stemmed = PorterStemmer.stemText(text);
    print('   "$text"');
    print('   → "$stemmed"\n');
  }

  print('📝 Stop words:');
  print('   Available stop words: ${PorterStemmer.stopWords.length}');
  print('   Examples: ${PorterStemmer.stopWords.take(10).join(", ")}...');

  print('\n');
}

// ============================================================================
// 6. DATASET CLEANING API
// Clean datasets before searching
// ============================================================================
Future<void> _datasetCleaningDemo() async {
  print('6️⃣ DATASET CLEANING API - StandardDatasetCleaner');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final messyProducts = [
    const Product(
      id: 1,
      name: 'Running Shoes',
      category: 'Sports',
      price: 89.99,
    ),
    const Product(
      id: 2,
      name: 'Running Shoes',
      category: 'Sports',
      price: 89.99,
    ), // Duplicate
    const Product(
      id: 3,
      name: 'RUNNING SHOES',
      category: 'Sports',
      price: 89.99,
    ), // Similar
    const Product(id: 4, name: '', category: '', price: 0.0), // Poor quality
    const Product(
      id: 5,
      name: 'Basketball Sneakers',
      category: 'Sports',
      price: 109.99,
    ),
    const Product(
      id: 6,
      name: 'Walking Boots',
      category: 'Outdoor',
      price: 129.99,
    ),
    const Product(
      id: 7,
      name: '   ',
      category: 'Invalid',
      price: -1.0,
    ), // Invalid
  ];

  print('\n🧹 Cleaning messy dataset (${messyProducts.length} items)');

  // Example 1: E-commerce cleaner
  print('\n📦 Example 1: E-commerce dataset cleaner');
  final ecommerceCleaner = StandardDatasetCleaner.forEcommerce<Product>();

  final ecommerceResult = ecommerceCleaner.cleanDataset(
    messyProducts,
    [(p) => p.name, (p) => p.category],
    qualityThreshold: 0.3,
    removeDuplicates: true,
    removeOutliers: true,
  );

  print('   Original: ${ecommerceResult.statistics.originalCount} items');
  print('   Cleaned: ${ecommerceResult.statistics.cleanedCount} items');
  print(
    '   Duplicates removed: ${ecommerceResult.statistics.duplicatesRemoved}',
  );
  print(
    '   Quality score: ${(ecommerceResult.statistics.qualityScore * 100).toStringAsFixed(1)}%',
  );
  print('   Processing time: ${ecommerceResult.statistics.processingTimeMs}ms');

  // Example 2: Minimal cleaner (less aggressive)
  print('\n📦 Example 2: Minimal dataset cleaner');
  final minimalCleaner = StandardDatasetCleaner.minimal<Product>();

  final minimalResult = minimalCleaner.cleanDataset(
    messyProducts,
    [(p) => p.name],
    qualityThreshold: 0.1, // Very low threshold
    removeDuplicates: false,
    removeOutliers: false,
  );

  print('   Original: ${minimalResult.statistics.originalCount} items');
  print('   Cleaned: ${minimalResult.statistics.cleanedCount} items');

  // Example 3: Aggressive cleaner
  print('\n📦 Example 3: Aggressive dataset cleaner');
  final aggressiveCleaner = StandardDatasetCleaner.aggressive<Product>();

  final aggressiveResult = aggressiveCleaner.cleanDataset(
    messyProducts,
    [(p) => p.name, (p) => p.category],
    qualityThreshold: 0.5, // High threshold
    removeDuplicates: true,
    removeOutliers: true,
  );

  print('   Original: ${aggressiveResult.statistics.originalCount} items');
  print('   Cleaned: ${aggressiveResult.statistics.cleanedCount} items');
  print(
    '   Duplicates removed: ${aggressiveResult.statistics.duplicatesRemoved}',
  );

  // Example 4: Use cleaned data in search
  print('\n🔍 Example 4: Search with cleaned dataset');
  final cleanedData = ecommerceResult.cleanedItems;

  final searchResults = await FuzzyBolt.searchWithScores<Product>(
    cleanedData,
    'running',
    selectors: [(p) => p.name],
  );

  print('   Found ${searchResults.length} results in cleaned dataset');
  for (final result in searchResults) {
    final score = (result.score * 100).toStringAsFixed(1);
    print('   ✓ ${result.item.name} - $score%');
  }

  print('\n');
}

// ============================================================================
// 7. PERFORMANCE DEMO
// Demonstrates performance with various dataset sizes
// ============================================================================
Future<void> _performanceDemo() async {
  print('7️⃣ PERFORMANCE DEMONSTRATION');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  // Small dataset
  print('\n⚡ Performance Test 1: Small dataset (100 items)');
  final small = List.generate(
    100,
    (i) => User(
      id: i,
      name: 'User$i',
      email: 'user$i@test.com',
      dept: 'Dept${i % 10}',
    ),
  );

  var stopwatch = Stopwatch()..start();
  var results = await FuzzyBolt.search<User>(
    small,
    'User50',
    selectors: [(u) => u.name],
  );
  stopwatch.stop();
  print('   Time: ${stopwatch.elapsedMilliseconds}ms');
  print('   Results: ${results.length} found');

  // Medium dataset
  print('\n⚡ Performance Test 2: Medium dataset (1,000 items)');
  final medium = List.generate(
    1000,
    (i) => User(
      id: i,
      name: 'MediumUser$i',
      email: 'medium$i@test.com',
      dept: 'Department${i % 20}',
    ),
  );

  stopwatch = Stopwatch()..start();
  results = await FuzzyBolt.search<User>(
    medium,
    'MediumUser500',
    selectors: [(u) => u.name],
    maxResults: 10,
  );
  stopwatch.stop();
  print('   Time: ${stopwatch.elapsedMilliseconds}ms');
  print('   Results: ${results.length} found');

  // Large dataset (will use isolates)
  print('\n⚡ Performance Test 3: Large dataset (5,000 items)');
  final large = List.generate(
    5000,
    (i) => User(
      id: i,
      name: 'LargeUser${i.toString().padLeft(5, "0")}',
      email: 'large$i@test.com',
      dept: 'Dept${i % 50}',
    ),
  );

  stopwatch = Stopwatch()..start();
  results = await FuzzyBolt.search<User>(
    large,
    'LargeUser02500',
    selectors: [(u) => u.name],
    isolateThreshold: 1000, // Force isolate usage
    maxResults: 10,
  );
  stopwatch.stop();
  print('   Time: ${stopwatch.elapsedMilliseconds}ms (with isolates)');
  print('   Results: ${results.length} found');

  // Text processing performance
  print('\n⚡ Performance Test 4: Heavy text processing (500 items)');
  final textHeavy = List.generate(
    500,
    (i) => Article(
      id: i,
      title:
          'Running jumping swimming cycling dancing singing playing walking $i',
      tags: 'sports, athletics, performance, training, professional',
    ),
  );

  stopwatch = Stopwatch()..start();
  final textResults = await FuzzyBolt.searchWithTextProcessing<Article>(
    textHeavy,
    'running athletic professional training',
    selectors: [(a) => a.title, (a) => a.tags],
    enableStemming: true,
    removeStopWords: true,
  );
  stopwatch.stop();
  print('   Time: ${stopwatch.elapsedMilliseconds}ms (with stemming)');
  print('   Results: ${textResults.length} found');

  print('\n');
}

// ============================================================================
// 8. CACHE MANAGEMENT API
// Manage FuzzyBolt's internal cache
// ============================================================================
Future<void> _cacheManagementDemo() async {
  print('8️⃣ CACHE MANAGEMENT API');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━');

  print('\n💾 Cache operations:');

  // Clear cache
  print('\n   1. Clearing cache...');
  FuzzyBolt.clearTextCache();

  var stats = FuzzyBolt.getTextCacheStats();
  print('      Cache size: ${stats["cacheSize"]}');
  print('      Max cache size: ${stats["maxCacheSize"]}');
  print(
    '      Utilization: ${(stats["utilization"] * 100).toStringAsFixed(1)}%',
  );

  // Perform searches to populate cache
  print('\n   2. Performing searches to populate cache...');
  final testData = [
    const Product(id: 1, name: 'Test Product', category: 'Test', price: 10.0),
  ];

  for (int i = 0; i < 5; i++) {
    await FuzzyBolt.searchWithTextProcessing<Product>(
      testData,
      'search query number $i',
      selectors: [(p) => p.name],
      enableStemming: true,
    );
  }

  stats = FuzzyBolt.getTextCacheStats();
  print('      Cache size after searches: ${stats["cacheSize"]}');
  print(
    '      Utilization: ${(stats["utilization"] * 100).toStringAsFixed(1)}%',
  );

  // Clear cache again
  print('\n   3. Clearing cache again...');
  FuzzyBolt.clearTextCache();

  stats = FuzzyBolt.getTextCacheStats();
  print('      Cache size after clear: ${stats["cacheSize"]}');

  print('\n   ✓ Cache management operations completed');

  print('\n');
}

// ============================================================================
// MODEL CLASSES
// ============================================================================

class Product {
  final int id;
  final String name;
  final String category;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  @override
  String toString() =>
      'Product(id: $id, name: "$name", category: "$category", price: \$${price.toStringAsFixed(2)})';
}

class User {
  final int id;
  final String name;
  final String email;
  final String dept;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.dept,
  });

  @override
  String toString() =>
      'User(id: $id, name: "$name", email: "$email", dept: "$dept")';
}

class Document {
  final int id;
  final String title;
  final String content;

  const Document({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  String toString() => 'Document(id: $id, title: "$title")';
}

class Article {
  final int id;
  final String title;
  final String tags;

  const Article({required this.id, required this.title, required this.tags});

  @override
  String toString() => 'Article(id: $id, title: "$title")';
}
