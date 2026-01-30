// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buck/components/usage_service.dart';
import 'package:buck/providers/usage_tracker.dart';
import 'package:buck/providers/favorit_provider.dart';
import 'package:buck/providers/bookmarks_provider.dart';
import 'package:buck/themes/theme_provider.dart';
import 'package:buck/splash.dart';
import 'package:buck/database_helper.dart';
import 'package:buck/models/hadith.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:buck/components/notification_helper.dart';
import 'package:buck/services/ad_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String dailyHadithTask = "dailyHadithTask";
// const String dailyHadithTask = "dailyHadithTask";
// Removed global flutterLocalNotificationsPlugin as we use NotificationHelper


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إصلاح Windows/Linux مع SQLite
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await DatabaseHelper.instance.resetDatabase();
  } catch (e) {
    debugPrint('Database reset error: $e');
  }

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(tz.local.name));

  await NotificationHelper.initNotifications();
  
  // Initialize Google Mobile Ads
  await AdService.initialize();

  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..loadFavorites()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => UsageTracker()..loadData()), // ✅ هنا
      ],
      child: const MyApp(),
    ),
  );
}

// Dispatcher ل WorkManager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    tz.initializeTimeZones();
    try {
      final Hadith? hadith = await DatabaseHelper.instance.getRandomHadith();
      if (hadith != null) {
          await NotificationHelper.showDailyNotification(hadith);
      }
    } catch (e) {
      debugPrint('Notification error: $e');
    }
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late UsageTracker tracker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tracker = Provider.of<UsageTracker>(context, listen: false);
    tracker.start(); // ✅ بدء العداد
  }

  @override
  void dispose() {
    tracker.stopAndSave(); // ✅ حفظ الوقت عند غلق التطبيق
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      tracker.stopAndSave(); // حفظ القيم عند الذهاب للخلفية
    } else if (state == AppLifecycleState.resumed) {
      tracker.start(); // استئناف العداد عند العودة
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "البخاري",
      theme: themeProvider.themeData,
      home: const SplashScreen(),
    );
  }
}

// ✅ إضافة UsageTracker مع الميثودات الناقصة
class UsageTracker extends ChangeNotifier {
  int dailySeconds = 0;
  int totalSeconds = 0;
  Timer? _timer;
  DateTime? _sessionStart;

  // تحميل البيانات القديمة
  Future<void> loadData() async {
    dailySeconds = await UsageService.getDailySeconds();
    totalSeconds = await UsageService.getTotalSeconds();
    notifyListeners();
  }

  // بدء العداد
  void start() {
    _sessionStart = DateTime.now();
    _timer?.cancel();
    // Use timer to increment seconds - this is the ONLY place we count time
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      dailySeconds++;
      totalSeconds++;
      notifyListeners();
    });
  }

  // إيقاف العداد وحفظ الوقت
  Future<void> stopAndSave() async {
    _timer?.cancel();
    _timer = null;
    
    // Save current values (already incremented by timer)
    await UsageService.saveDailySeconds(dailySeconds);
    await UsageService.saveTotalSeconds(totalSeconds);
    
    _sessionStart = null;
    notifyListeners();
  }
}
