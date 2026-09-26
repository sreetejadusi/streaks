class Habit {
  final String id;
  final String title;
  final String streak;
  final String time;
  final bool isDone;
  final List<String> completedDates;
  final int typeIndex;
  final String iconEmoji;
  final List<int> repeatDays;
  final int startDate;
  final int orderIndex;

  const Habit({
    required this.id,
    required this.title,
    required this.streak,
    required this.time,
    required this.isDone,
    this.completedDates = const [],
    required this.typeIndex,
    this.iconEmoji = '🎯',
    this.repeatDays = const [0, 1, 2, 3, 4, 5, 6],
    this.startDate = 0,
    this.orderIndex = 0,
  });
}
