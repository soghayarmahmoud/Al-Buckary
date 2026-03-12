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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database init encountered an error: $e');
  }

  await UsageService.logToday();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(tz.local.name));

  await NotificationHelper.initNotifications();

  await AdService.initialize();

  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..loadFavorites(),
        ),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(
          create: (_) => UsageTracker()..loadData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

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
    tracker.start();
  }

  @override
  void dispose() {
    tracker.stopAndSave();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      tracker.stopAndSave();
    } else if (state == AppLifecycleState.resumed) {
      tracker.start();
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

class UsageTracker extends ChangeNotifier {
  int dailySeconds = 0;
  int totalSeconds = 0;
  Timer? _timer;
  DateTime? _sessionStart;

  Future<void> loadData() async {
    dailySeconds = await UsageService.getDailySeconds();
    totalSeconds = await UsageService.getTotalSeconds();
    notifyListeners();
  }

  void start() {
    _sessionStart = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      dailySeconds++;
      totalSeconds++;
      notifyListeners();
    });
  }

  Future<void> stopAndSave() async {
    _timer?.cancel();
    _timer = null;

    await UsageService.saveDailySeconds(dailySeconds);
    await UsageService.saveTotalSeconds(totalSeconds);

    _sessionStart = null;
    notifyListeners();
  }
}
