import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:buck/components/usage_service.dart';
import 'package:buck/database_helper.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with WidgetsBindingObserver {
  List<DateTime> openedDays = [];
  int streak = 0;
  int totalSeconds = 0;
  Map<DateTime, int> last7Days = {};
  int notesCount = 0;
  int collectionsCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadData() async {
    final days = await UsageService.getAllDays();
    final s = await UsageService.getStreak();

    final total = await UsageService.getTotalSeconds();
    final last7 = await UsageService.getLastNDays(7);

    final notes = await DatabaseHelper.instance.getAllNotes();
    final collections = await DatabaseHelper.instance.getCollections();

    setState(() {
      openedDays = days;
      streak = s;
      totalSeconds = total;
      last7Days = last7;
      notesCount = notes.length;
      collectionsCount = collections.length;
    });
  }

  bool _isOpenedDay(DateTime day) {
    return openedDays.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الإحصائيات",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: today,

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final dayOnly = DateTime(day.year, day.month, day.day);

                  bool isOpened = _isOpenedDay(dayOnly);
                  bool isPast = dayOnly.isBefore(today);
                  bool isFuture = dayOnly.isAfter(today);

                  if (isOpened) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (isPast && !isOpened) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (isFuture) {
                    return Center(
                      child: Text("${day.day}"),
                    );
                  }

                  return null;
                },

                todayBuilder: (context, day, _) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${day.day}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'ستريك',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'إجمالي الوقت (دقائق)',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(totalSeconds / 60).round()}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'الملاحظات',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$notesCount',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'المجموعات',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$collectionsCount',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "عدد الأيام المتتالية التي واظبت فيها على فتح التطبيق",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const Divider(height: 40, thickness: 2),
          ],
        ),
      ),
    );
  }
}