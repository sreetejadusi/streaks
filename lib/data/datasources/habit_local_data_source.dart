import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';

abstract class HabitLocalDataSource {
  Future<List<HabitModel>> getHabits();
  Future<void> cacheHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final Box<HabitModel> habitBox = Hive.box<HabitModel>('habits');

  @override
  Future<List<HabitModel>> getHabits() async {
    return habitBox.values.toList();
  }

  @override
  Future<void> cacheHabit(HabitModel habit) async {
    await habitBox.put(habit.id, habit);
  }
  
  @override
  Future<void> updateHabit(HabitModel habit) async {
    await habitBox.put(habit.id, habit);
  }
}
