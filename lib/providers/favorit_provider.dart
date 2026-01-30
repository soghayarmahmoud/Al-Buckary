import 'package:flutter/material.dart';
import 'package:buck/models/hadith.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/services/notification_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<int> _favoriteIds = [];

  List<int> get favoriteIds => _favoriteIds;

  bool isFavorite(int hadithId) {
    return _favoriteIds.contains(hadithId);
  }

  Future<void> loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavoriteHadiths();
    _favoriteIds.clear();
    _favoriteIds.addAll(favorites.map((h) => h.id));
    notifyListeners();
  }

  Future<void> toggleFavorite(Hadith hadith, BuildContext context) async {
    final isFav = isFavorite(hadith.id);

    if (isFav) {
      _favoriteIds.remove(hadith.id);
      await DatabaseHelper.instance.toggleFavorite(hadith.id, false);
      if (context.mounted) {
        NotificationService.showError(context, 'تم إزالة الحديث من المفضلة');
      }
    } else {
      _favoriteIds.add(hadith.id);
      await DatabaseHelper.instance.toggleFavorite(hadith.id, true);
      if (context.mounted) {
        NotificationService.showSuccess(context, 'تمت إضافة الحديث للمفضلة ⭐');
      }
    }

    notifyListeners();
  }
}
