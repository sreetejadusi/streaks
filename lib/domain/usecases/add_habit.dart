import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class AddHabit {
  final HabitRepository repository;

  AddHabit(this.repository);

  Future<void> call(Habit habit) {
    return repository.addHabit(habit);
  }
}
