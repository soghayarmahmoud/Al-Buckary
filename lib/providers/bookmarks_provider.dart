import 'package:flutter/material.dart';
import 'package:buck/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksProvider extends ChangeNotifier {
  Map<int, int> _bookmarks = {}; // chapterId -> hadithId

  BookmarksProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    // Load from DB
    _bookmarks = {};
    try {
      final rows = await DatabaseHelper.instance.getAllBookmarks();
      for (var r in rows) {
        final chapterId = r['chapter_id'] as int;
        final hadithId = r['hadith_id'] as int;
        _bookmarks[chapterId] = hadithId;
      }
    } catch (e) {
      // If DB isn't ready or table missing, fall back to empty map
      debugPrint('Error loading bookmarks from DB: $e');
      _bookmarks = {};
    }

    // Migrate any legacy SharedPreferences bookmarks into DB
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith('bookmark_')) {
          final chapterId = int.tryParse(key.replaceFirst('bookmark_', ''));
          final hadithId = prefs.getInt(key);
          if (chapterId != null &&
              hadithId != null &&
              !_bookmarks.containsKey(chapterId)) {
            await DatabaseHelper.instance.setBookmark(chapterId, hadithId);
            _bookmarks[chapterId] = hadithId;
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      debugPrint('Bookmarks migration error: $e');
    }

    // Notify after migration as well
    notifyListeners();
  }

  int? getBookmark(int chapterId) => _bookmarks[chapterId];

  Future<void> setBookmark(int chapterId, int hadithId) async {
    await DatabaseHelper.instance.setBookmark(chapterId, hadithId);
    _bookmarks[chapterId] = hadithId;
    notifyListeners();
  }

  Future<void> removeBookmark(int chapterId) async {
    await DatabaseHelper.instance.removeBookmark(chapterId);
    _bookmarks.remove(chapterId);
    notifyListeners();
  }
}
