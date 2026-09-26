import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class ToggleHabitStatus {
  final HabitRepository repository;

  ToggleHabitStatus(this.repository);

  Future<void> call(Habit habit, String dateStr) {
    final List<String> updatedDates = List.from(habit.completedDates);
    if (updatedDates.contains(dateStr)) {
      updatedDates.remove(dateStr);
    } else {
      updatedDates.add(dateStr);
    }

    final updatedHabit = Habit(
      id: habit.id,
      title: habit.title,
      streak: '${updatedDates.length} days',
      time: habit.time,
      isDone: habit.isDone, 
      typeIndex: habit.typeIndex,
      iconEmoji: habit.iconEmoji,
      repeatDays: habit.repeatDays,
      startDate: habit.startDate,
      orderIndex: habit.orderIndex,
      completedDates: updatedDates,
    );
    return repository.updateHabit(updatedHabit);
  }
}
