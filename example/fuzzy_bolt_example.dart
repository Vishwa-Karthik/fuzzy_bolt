import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() async {
  print('🔍 FuzzyBolt - Advanced Fuzzy Search Engine Demo\n');

  await _userSearchDemo();
  await _productSearchDemo();
  await _advancedConfigDemo();
  await _performanceDemo();
}

Future<void> _userSearchDemo() async {
  print('👥 User Search Demo');
  print('==================');

  final users = [
    const User(
      id: 1,
      name: "Alice Johnson",
      email: "alice@company.com",
      department: "Engineering",
    ),
    const User(
      id: 2,
      name: "Bob Smith",
      email: "bob@company.com",
      department: "Marketing",
    ),
    const User(
      id: 3,
      name: "Charlie Brown",
      email: "charlie@company.com",
      department: "Sales",
    ),
    const User(
      id: 4,
      name: "Diana Prince",
      email: "diana@company.com",
      department: "Engineering",
    ),
    const User(
      id: 5,
      name: "Eve Davis",
      email: "eve@company.com",
      department: "HR",
    ),
    const User(
      id: 6,
      name: "Frank Miller",
      email: "frank@company.com",
      department: "Engineering",
    ),
    const User(
      id: 7,
      name: "Grace Lee",
      email: "grace@company.com",
      department: "Design",
    ),
    const User(
      id: 8,
      name: "Henry Wilson",
      email: "henry@company.com",
      department: "Engineering",
    ),
  ];

  // Example 1: Basic search by name
  print('1. Search for "Ali" (typo in Alice):');
  final aliceResults = await FuzzyBolt.search<User>(
    users,
    "Ali",
    selectors: [(u) => u.name],
    typeThreshold: 0.6,
  );
  _printUsers(aliceResults);

  // Example 2: Search multiple fields
  print('\\n 2. Search "eng" across name and department:');
  final engResults = await FuzzyBolt.searchWithScores<User>(
    users,
    "eng",
    selectors: [(u) => u.name, (u) => u.department],
    typeThreshold: 0.5,
  );
  _printUserResults(engResults);

  // Example 3: Exact email search
  print('\\n 3. Search for exact email "alice@company.com":');
  final emailResults = await FuzzyBolt.search<User>(
    users,
    "alice@company.com",
    selectors: [(u) => u.email],
    strictThreshold: 0.95,
  );
  _printUsers(emailResults);

  print('\\n');
}

Future<void> _productSearchDemo() async {
  print('🛍️ Product Search Demo');
  print('=====================');

  final products = [
    const Product(
      name: "iPhone 15 Pro",
      category: "Electronics",
      description: "Latest smartphone with advanced camera",
      price: 999.99,
    ),
    const Product(
      name: "MacBook Air",
      category: "Electronics",
      description: "Lightweight laptop for professionals",
      price: 1299.99,
    ),
    const Product(
      name: "AirPods Pro",
      category: "Electronics",
      description: "Wireless earbuds with noise cancellation",
      price: 249.99,
    ),
    const Product(
      name: "Coffee Maker",
      category: "Kitchen",
      description: "Automatic drip coffee machine",
      price: 89.99,
    ),
    const Product(
      name: "Running Shoes",
      category: "Sports",
      description: "Comfortable athletic footwear",
      price: 129.99,
    ),
    const Product(
      name: "Yoga Mat",
      category: "Sports",
      description: "Non-slip exercise mat",
      price: 39.99,
    ),
  ];

  // Example 1: Search by product name with typos
  print('1. Search "iphone" (case insensitive):');
  final iphoneResults = await FuzzyBolt.searchWithScores<Product>(
    products,
    "iphone",
    selectors: [(p) => p.name],
    typeThreshold: 0.6,
  );
  _printProductResults(iphoneResults);

  // Example 2: Search across all fields
  print('\\n 2. Search "wireless" across all fields:');
  final wirelessResults = await FuzzyBolt.search<Product>(
    products,
    "wireless",
    selectors: [(p) => p.name, (p) => p.category, (p) => p.description],
    typeThreshold: 0.5,
  );
  _printProducts(wirelessResults);

  // Example 3: Category-specific search
  print('\\n 3. Search "sport" in categories:');
  final sportsResults = await FuzzyBolt.search<Product>(
    products,
    "sport",
    selectors: [(p) => p.category],
    typeThreshold: 0.7,
  );
  _printProducts(sportsResults);

  print('\\n');
}

Future<void> _advancedConfigDemo() async {
  print('⚙️ Advanced Configuration Demo');
  print('=============================');

  final items = [
    "artificial intelligence",
    "machine learning",
    "deep learning",
    "neural networks",
    "data science",
    "computer vision",
    "natural language processing",
  ];

  // Custom configuration
  final config = FuzzySearchConfig(
    strictThreshold: 0.9,
    typeThreshold: 0.6,
    maxResults: 3,
    skipIsolate: true, // Force synchronous processing
  );

  print('Search "artifical inteligence" (typos) with custom config:');
  final results = await FuzzyBolt.searchWithConfig<String>(
    items,
    "artifical inteligence",
    [(item) => item],
    config,
  );

  for (final result in results) {
    print('  📋 ${result.item} (score: ${result.score.toStringAsFixed(3)})');
  }

  print('\\n');
}

Future<void> _performanceDemo() async {
  print('🚀 Performance Demo');
  print('==================');

  // Generate a large dataset
  final largeDataset = List.generate(
    5000,
    (i) => User(
      id: i,
      name: "User\${i.toString().padLeft(4, '0')}",
      email: "user\$i@example.com",
      department: ["Engineering", "Marketing", "Sales", "HR", "Design"][i % 5],
    ),
  );

  print('Searching 5,000 users for "User1234":');
  final stopwatch = Stopwatch()..start();

  final results = await FuzzyBolt.search<User>(
    largeDataset,
    "User1234",
    selectors: [(u) => u.name],
    isolateThreshold: 1000, // Will use isolates for this large dataset
    maxResults: 5,
  );

  stopwatch.stop();

  print(
    'Found ${results.length} results in ${stopwatch.elapsedMilliseconds}ms',
  );
  for (final user in results.take(3)) {
    print('  👤 ${user.name} (${user.email})');
  }

  print('\\n');
}

void _printUsers(List<User> users) {
  for (final user in users) {
    print('  👤 ${user.name} (${user.department})');
  }
}

void _printUserResults(List<FuzzyResult<User>> results) {
  for (final result in results) {
    print(
      '  👤 ${result.item.name} (${result.item.department}) - Score: ${result.score.toStringAsFixed(3)}',
    );
  }
}

void _printProducts(List<Product> products) {
  for (final product in products) {
    print('  🛍️ ${product.name} - \$${product.price}');
  }
}

void _printProductResults(List<FuzzyResult<Product>> results) {
  for (final result in results) {
    print(
      '  🛍️ ${result.item.name} - Score: ${result.score.toStringAsFixed(3)}',
    );
  }
}

// Example models
class User {
  final int id;
  final String name;
  final String email;
  final String department;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  @override
  String toString() =>
      'User(id: $id, name: "$name", email: "$email", department: "$department")';
}

class Product {
  final String name;
  final String category;
  final String description;
  final double price;

  const Product({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
  });

  @override
  String toString() =>
      'Product(name: "$name", category: "$category", price: \$$price)';
}
