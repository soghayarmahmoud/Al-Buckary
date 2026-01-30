import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UsageService {
  static const String key = "opened_days";
  static const String lastStreakResetKey = "last_streak_reset_date";

  // ============================
  // 🔹 جزء تتبع الأيام والستريك
  // ============================

  // تسجيل فتح البرنامج - محسّن ومبسط
  static Future<void> logToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    List<String> days = prefs.getStringList(key) ?? [];

    if (!days.contains(today)) {
      days.add(today);
      await prefs.setStringList(key, days);
    }
  }

  // جلب كل الأيام
  static Future<List<DateTime>> getAllDays() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> days = prefs.getStringList(key) ?? [];
    return days.map((e) => DateTime.parse(e)).toList();
  }

  // حساب الستريك (الأيام المتتالية) - منطق قوي
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> daysRaw = prefs.getStringList(key) ?? [];
    if (daysRaw.isEmpty) return 0;

    // 1. تحويل إلى كائنات DateTime فريدة (بدون وقت)
    Set<String> uniqueDays = daysRaw.toSet();
    List<DateTime> days = uniqueDays.map((e) => DateTime.parse(e)).toList();

    // 2. ترتيب تنازلي (الأحدث أولاً)
    days.sort((a, b) => b.compareTo(a));

    if (days.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // 3. تحديد نقطة البداية
    // الستريك مستمر إذا فتحنا التطبيق اليوم أو أمس
    // إذا كان آخر فتح قبل أمس، فالستريك انقطع
    
    DateTime lastOpened = days.first;
    
    if (!lastOpened.isAtSameMomentAs(today) && !lastOpened.isAtSameMomentAs(yesterday)) {
       return 0;
    }

    // 4. حساب الأيام المتتالية
    int streak = 1;
    DateTime currentDate = lastOpened;

    for (int i = 1; i < days.length; i++) {
      final prevDate = days[i];
      final difference = currentDate.difference(prevDate).inDays;

      if (difference == 1) {
        streak++;
        currentDate = prevDate;
      } else {
        break; 
      }
    }

    return streak;
  }

  static Future<void> saveDailySeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayKey = "daily_$today";
    await prefs.setInt(todayKey, seconds);
  }

  /// استرجاع الوقت اليومي (بالثواني)
  static Future<int> getDailySeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayKey = "daily_$today";
    return prefs.getInt(todayKey) ?? 0;
  }

  /// Get daily seconds for a specific date (yyyy-MM-dd)
  static Future<int> getDailySecondsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = DateFormat('yyyy-MM-dd').format(date);
    return prefs.getInt('daily_$key') ?? 0;
  }

  /// Get last N days (date -> seconds) with today included. Returns map with DateTime keys.
  static Future<Map<DateTime, int>> getLastNDays(int n) async {
    final Map<DateTime, int> data = {};
    final now = DateTime.now();
    for (int i = 0; i < n; i++) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final seconds = await getDailySecondsForDate(d);
      data[d] = seconds;
    }
    return data;
  }

  /// حفظ الوقت الكلي (بالثواني)
  static Future<void> saveTotalSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("total_seconds", seconds);
  }

  /// استرجاع الوقت الكلي (بالثواني)
  static Future<int> getTotalSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("total_seconds") ?? 0;
  }
}
