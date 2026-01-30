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
  // الكود القديم
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

  // تحميل البيانات القديمة (أيام + ستريك)
  Future<void> _loadData() async {
    final days = await UsageService.getAllDays();
    final s = await UsageService.getStreak();

    final total = await UsageService.getTotalSeconds();
    final last7 = await UsageService.getLastNDays(7);

    // Fetch DB stats
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

  @override
  Widget build(BuildContext context) {
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
            // التقويم
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: DateTime.now(),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  if (_isOpenedDay(day)) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
            // Summary cards
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
            // New Stats Row
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
            const SizedBox(height: 18),
            // Weekly bar chart (simple)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'آخر 7 أيام',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: last7Days.entries.map((entry) {
                            final max = last7Days.values.fold<int>(
                              1,
                              (p, e) => e > p ? e : p,
                            );
                            final heightFactor = max == 0
                                ? 0.0
                                : (entry.value / max);
                            final label = '${entry.key.day}/${entry.key.month}';
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 90 * heightFactor + 6,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 40, thickness: 2),
          ],
        ),
      ),
    );
  }
}
