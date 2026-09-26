import '../entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getDailyHabits();
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
}
