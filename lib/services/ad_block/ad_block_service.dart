import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'blocklist_engine.dart';

class AdBlockService extends ChangeNotifier {
  bool _enabled = true;
  int _blockedCount = 0;
  int _skippedAdsCount = 0;

  bool get isEnabled => _enabled;
  int get blockedCount => _blockedCount;
  int get skippedAdsCount => _skippedAdsCount;

  late BlocklistEngine _engine;

  Future<void> initialize() async {
    try {
      final rules = await rootBundle.loadString('assets/ad_block/rules.txt');
      _engine = BlocklistEngine.parse(rules);
    } catch (e) {
      if (kDebugMode) print('AdBlockService initialization error: $e');
      _engine = BlocklistEngine.parse('');
    }
  }

  bool shouldBlock(String url) {
    if (!_enabled) return false;
    final blocked = _engine.matches(url);
    if (blocked) {
      _blockedCount++;
      notifyListeners();
    }
    return blocked;
  }

  void recordSkippedAd() {
    _skippedAdsCount++;
    notifyListeners();
  }

  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void resetStats() {
    _blockedCount = 0;
    _skippedAdsCount = 0;
    notifyListeners();
  }

  Future<void> reloadRules(String rulesText) async {
    _engine = BlocklistEngine.parse(rulesText);
    notifyListeners();
  }
}
