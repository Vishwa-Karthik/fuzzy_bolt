import '../interfaces/text_processor.dart';

/// Porter Stemming Algorithm implementation for English text
/// Based on Martin Porter's stemming algorithm for reducing words to their root form
class PorterStemmer implements TextProcessor {
  static final Map<String, String> _cache = <String, String>{};
  static int _cacheHits = 0;
  static int _totalRequests = 0;

  // Common English stop words
  static const Set<String> _stopWords = {
    'a',
    'an',
    'and',
    'are',
    'as',
    'at',
    'be',
    'by',
    'for',
    'from',
    'has',
    'he',
    'in',
    'is',
    'it',
    'its',
    'of',
    'on',
    'that',
    'the',
    'to',
    'was',
    'will',
    'with',
    'this',
    'but',
    'they',
    'have',
    'had',
    'what',
    'said',
    'each',
    'which',
    'she',
    'do',
    'how',
    'their',
    'if',
    'up',
    'out',
    'many',
    'then',
    'them',
    'these',
    'so',
    'some',
    'her',
    'would',
    'make',
    'like',
    'into',
    'him',
    'time',
    'two',
    'more',
    'go',
    'no',
    'way',
    'could',
    'my',
    'than',
    'first',
    'been',
    'call',
    'who',
    'oil',
    'sit',
    'now',
    'find',
    'down',
    'day',
    'did',
    'get',
    'come',
    'made',
    'may',
    'part',
  };

  @override
  String get processorName => 'Porter Stemmer';

  @override
  bool supportsLanguage(String languageCode) {
    return languageCode.toLowerCase() == 'en' ||
        languageCode.toLowerCase() == 'english';
  }

  @override
  void reset() {
    _cache.clear();
    _cacheHits = 0;
    _totalRequests = 0;
  }

  @override
  Map<String, dynamic> getStatistics() {
    final hitRate = _totalRequests > 0 ? _cacheHits / _totalRequests : 0.0;
    return {
      'cacheSize': _cache.length,
      'cacheHits': _cacheHits,
      'totalRequests': _totalRequests,
      'hitRate': hitRate,
      'processorName': processorName,
    };
  }

  @override
  String processWord(String word) {
    return stem(word);
  }

  @override
  String processText(String text) {
    return stemText(text);
  }

  /// Stem a single word using Porter's algorithm
  static String stem(String word) {
    _totalRequests++;

    if (word.length <= 2) return word.toLowerCase();

    final lowerWord = word.toLowerCase();

    // Check cache first
    if (_cache.containsKey(lowerWord)) {
      _cacheHits++;
      return _cache[lowerWord]!;
    }

    final stemmed = _performStemming(lowerWord);
    _cache[lowerWord] = stemmed;

    return stemmed;
  }

  /// Stem text by processing individual words
  static String stemText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !_stopWords.contains(word))
        .map((word) => stem(word))
        .join(' ');
  }

  /// Core Porter stemming algorithm implementation
  static String _performStemming(String word) {
    if (word.length <= 2) return word;

    String result = word;

    // Step 1a
    result = _step1a(result);

    // Step 1b
    result = _step1b(result);

    // Step 1c
    result = _step1c(result);

    // Step 2
    result = _step2(result);

    // Step 3
    result = _step3(result);

    // Step 4
    result = _step4(result);

    // Step 5
    result = _step5(result);

    return result;
  }

  static String _step1a(String word) {
    if (word.endsWith('sses')) {
      return word.substring(0, word.length - 2);
    } else if (word.endsWith('ies')) {
      return word.substring(0, word.length - 2);
    } else if (word.endsWith('ss')) {
      return word;
    } else if (word.endsWith('s') && word.length > 1) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  static String _step1b(String word) {
    if (word.endsWith('eed')) {
      final stem = word.substring(0, word.length - 3);
      if (_measure(stem) > 0) {
        return '${stem}ee';
      }
      return word;
    } else if (word.endsWith('ed')) {
      final stem = word.substring(0, word.length - 2);
      if (_containsVowel(stem)) {
        String result = stem;
        if (result.endsWith('at') ||
            result.endsWith('bl') ||
            result.endsWith('iz')) {
          result += 'e';
        } else if (_endsWithDoubleConsonant(result) &&
            !result.endsWith('l') &&
            !result.endsWith('s') &&
            !result.endsWith('z')) {
          result = result.substring(0, result.length - 1);
        } else if (_measure(result) == 1 && _cvc(result)) {
          result += 'e';
        }
        return result;
      }
      return word;
    } else if (word.endsWith('ing')) {
      final stem = word.substring(0, word.length - 3);
      if (_containsVowel(stem)) {
        String result = stem;
        if (result.endsWith('at') ||
            result.endsWith('bl') ||
            result.endsWith('iz')) {
          result += 'e';
        } else if (_endsWithDoubleConsonant(result) &&
            !result.endsWith('l') &&
            !result.endsWith('s') &&
            !result.endsWith('z')) {
          result = result.substring(0, result.length - 1);
        } else if (_measure(result) == 1 && _cvc(result)) {
          result += 'e';
        }
        return result;
      }
      return word;
    }
    return word;
  }

  static String _step1c(String word) {
    if (word.length > 1 &&
        word.endsWith('y') &&
        _containsVowel(word.substring(0, word.length - 1))) {
      return '${word.substring(0, word.length - 1)}i';
    }
    return word;
  }

  static String _step2(String word) {
    final suffixes = {
      'ational': 'ate',
      'tional': 'tion',
      'enci': 'ence',
      'anci': 'ance',
      'izer': 'ize',
      'abli': 'able',
      'alli': 'al',
      'entli': 'ent',
      'eli': 'e',
      'ousli': 'ous',
      'ization': 'ize',
      'ation': 'ate',
      'ator': 'ate',
      'alism': 'al',
      'iveness': 'ive',
      'fulness': 'ful',
      'ousness': 'ous',
      'aliti': 'al',
      'iviti': 'ive',
      'biliti': 'ble',
    };

    for (final entry in suffixes.entries) {
      if (word.endsWith(entry.key)) {
        final stem = word.substring(0, word.length - entry.key.length);
        if (_measure(stem) > 0) {
          return stem + entry.value;
        }
        break;
      }
    }
    return word;
  }

  static String _step3(String word) {
    final suffixes = {
      'icate': 'ic',
      'ative': '',
      'alize': 'al',
      'iciti': 'ic',
      'ical': 'ic',
      'ful': '',
      'ness': '',
    };

    for (final entry in suffixes.entries) {
      if (word.endsWith(entry.key)) {
        final stem = word.substring(0, word.length - entry.key.length);
        if (_measure(stem) > 0) {
          return stem + entry.value;
        }
        break;
      }
    }
    return word;
  }

  static String _step4(String word) {
    final suffixes = [
      'al',
      'ance',
      'ence',
      'er',
      'ic',
      'able',
      'ible',
      'ant',
      'ement',
      'ment',
      'ent',
      'ion',
      'ou',
      'ism',
      'ate',
      'iti',
      'ous',
      'ive',
      'ize',
    ];

    for (final suffix in suffixes) {
      if (word.endsWith(suffix)) {
        final stem = word.substring(0, word.length - suffix.length);
        if (_measure(stem) > 1) {
          if (suffix == 'ion' && (stem.endsWith('s') || stem.endsWith('t'))) {
            return stem;
          } else if (suffix != 'ion') {
            return stem;
          }
        }
        break;
      }
    }
    return word;
  }

  static String _step5(String word) {
    if (word.endsWith('e')) {
      final stem = word.substring(0, word.length - 1);
      final m = _measure(stem);
      if (m > 1 || (m == 1 && !_cvc(stem))) {
        return stem;
      }
    } else if (word.endsWith('l') &&
        _measure(word) > 1 &&
        word.length > 1 &&
        word[word.length - 2] == 'l') {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  static int _measure(String word) {
    if (word.isEmpty) return 0;

    int m = 0;
    bool vowelSeen = false;

    for (int i = 0; i < word.length; i++) {
      final isVowel = _isVowel(word, i);

      if (isVowel) {
        vowelSeen = true;
      } else if (vowelSeen) {
        m++;
        vowelSeen = false;
      }
    }

    return m;
  }

  static bool _containsVowel(String word) {
    for (int i = 0; i < word.length; i++) {
      if (_isVowel(word, i)) {
        return true;
      }
    }
    return false;
  }

  static bool _isVowel(String word, int index) {
    if (index < 0 || index >= word.length) return false;

    final char = word[index];
    if ('aeiou'.contains(char)) return true;

    if (char == 'y' && index > 0 && !_isVowel(word, index - 1)) {
      return true;
    }

    return false;
  }

  static bool _endsWithDoubleConsonant(String word) {
    if (word.length < 2) return false;

    final last = word[word.length - 1];
    final secondLast = word[word.length - 2];

    return last == secondLast && !_isVowel(word, word.length - 1);
  }

  static bool _cvc(String word) {
    if (word.length < 3) return false;

    final len = word.length;
    return !_isVowel(word, len - 3) &&
        _isVowel(word, len - 2) &&
        !_isVowel(word, len - 1) &&
        word[len - 1] != 'w' &&
        word[len - 1] != 'x' &&
        word[len - 1] != 'y';
  }

  /// Get the current cache size
  static int get cacheSize => _cache.length;

  /// Get cache hit statistics
  static double get hitRate =>
      _totalRequests > 0 ? _cacheHits / _totalRequests : 0.0;

  /// Get stop words set
  static Set<String> get stopWords => _stopWords;
}
