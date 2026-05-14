class DailyInsightStat {
  const DailyInsightStat({
    required this.date,
    required this.label,
    required this.completedCount,
  });

  final DateTime date;
  final String label;
  final int completedCount;
}
