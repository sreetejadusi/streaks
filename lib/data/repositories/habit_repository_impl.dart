import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_data_source.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl(this.localDataSource);

  @override
  Future<List<Habit>> getDailyHabits() async {
    return await localDataSource.getHabits();
  }

  @override
  Future<void> addHabit(Habit habit) async {
    final model = HabitModel(
      id: habit.id,
      title: habit.title,
      streak: habit.streak,
      time: habit.time,
      isDone: habit.isDone,
      typeIndex: habit.typeIndex,
      iconEmoji: habit.iconEmoji,
      repeatDays: habit.repeatDays,
      startDate: habit.startDate,
      orderIndex: habit.orderIndex,
      completedDates: habit.completedDates,
    );
    await localDataSource.cacheHabit(model);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final model = HabitModel(
      id: habit.id,
      title: habit.title,
      streak: habit.streak,
      time: habit.time,
      isDone: habit.isDone,
      typeIndex: habit.typeIndex,
      iconEmoji: habit.iconEmoji,
      repeatDays: habit.repeatDays,
      startDate: habit.startDate,
      orderIndex: habit.orderIndex,
      completedDates: habit.completedDates,
    );
    await localDataSource.updateHabit(model);
  }
}
