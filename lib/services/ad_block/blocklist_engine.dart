class BlocklistEngine {
  final List<RegExp> _blockPatterns;
  final List<RegExp> _allowPatterns;
  final List<String> _cosmeticSelectors;

  BlocklistEngine._({
    required List<RegExp> blockPatterns,
    required List<RegExp> allowPatterns,
    required List<String> cosmeticSelectors,
  })  : _blockPatterns = blockPatterns,
        _allowPatterns = allowPatterns,
        _cosmeticSelectors = cosmeticSelectors;

  factory BlocklistEngine.parse(String rules) {
    final blocks = <RegExp>[];
    final allows = <RegExp>[];
    final cosmetic = <String>[];

    for (final line in rules.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('!')) continue;

      if (trimmed.startsWith('@@')) {
        final pattern = _ruleToRegex(trimmed.substring(2));
        if (pattern != null) allows.add(pattern);
      } else if (trimmed.contains('##')) {
        final parts = trimmed.split('##');
        if (parts.length == 2) cosmetic.add(parts[1]);
      } else {
        final pattern = _ruleToRegex(trimmed);
        if (pattern != null) blocks.add(pattern);
      }
    }

    return BlocklistEngine._(
      blockPatterns: blocks,
      allowPatterns: allows,
      cosmeticSelectors: cosmetic,
    );
  }

  static RegExp? _ruleToRegex(String rule) {
    try {
      final noOptions = rule.contains('\$') ? rule.split('\$').first : rule;

      var pattern = noOptions
          .replaceAll('.', r'\.')
          .replaceAll('||', r'https?://(?:[^/]+\.)?')
          .replaceAll('^', r'(?:[/?#]|$)')
          .replaceAll('*', '.*');

      return RegExp(pattern, caseSensitive: false);
    } catch (_) {
      return null;
    }
  }

  bool matches(String url) {
    for (final allow in _allowPatterns) {
      if (allow.hasMatch(url)) return false;
    }
    for (final block in _blockPatterns) {
      if (block.hasMatch(url)) return true;
    }
    return false;
  }

  List<String> get cosmeticSelectors => List.unmodifiable(_cosmeticSelectors);
}
