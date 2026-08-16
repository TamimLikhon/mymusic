import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_block_service.dart';

class BlocklistUpdater {
  // Use raw github url or any cdn where the rules.txt is hosted
  static const _remoteUrl = 'https://raw.githubusercontent.com/YOUR_REPO/mymusic-adblock/main/rules.txt';
  static const _lastUpdateKey = 'adblock_last_update';
  static const _updateIntervalDays = 3;

  final AdBlockService _adBlockService;
  final SharedPreferences _prefs;

  BlocklistUpdater(this._adBlockService, this._prefs);

  Future<void> checkAndUpdate() async {
    final lastUpdate = _prefs.getInt(_lastUpdateKey) ?? 0;
    final daysSinceLast = (DateTime.now().millisecondsSinceEpoch - lastUpdate) / Duration.millisecondsPerDay;

    // Optional: Load from disk first if there are newer rules stored locally
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/adblock_rules.txt');
      if (await file.exists()) {
        final localRules = await file.readAsString();
        if (localRules.isNotEmpty) {
          await _adBlockService.reloadRules(localRules);
        }
      }
    } catch (e) {
      if (kDebugMode) print('[AdBlock] Could not load local rules: $e');
    }

    if (daysSinceLast < _updateIntervalDays) return;

    try {
      final response = await http.get(Uri.parse(_remoteUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/adblock_rules.txt');
        await file.writeAsString(response.body);

        await _adBlockService.reloadRules(response.body);

        await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
        if (kDebugMode) print('[AdBlock] Rules updated from remote.');
      }
    } catch (e) {
      if (kDebugMode) print('[AdBlock] Remote update failed (using bundled rules): $e');
    }
  }
}
