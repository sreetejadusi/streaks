import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';
import '../../domain/entities/habit.dart';
import 'new_habit_screen.dart';

class AllHabitsScreen extends StatefulWidget {
  const AllHabitsScreen({super.key});

  @override
  State<AllHabitsScreen> createState() => _AllHabitsScreenState();
}

class _AllHabitsScreenState extends State<AllHabitsScreen> {
  List<Habit> _allHabits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    final habitsBox = Hive.box<HabitModel>('habits');
    setState(() {
      _allHabits = habitsBox.values.toList();
      _allHabits.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    });
  }
  
  void _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final Habit habit = _allHabits.removeAt(oldIndex);
      _allHabits.insert(newIndex, habit);
    });
    
    final box = Hive.box<HabitModel>('habits');
    for (int i = 0; i < _allHabits.length; i++) {
      final h = _allHabits[i];
      final model = HabitModel(
        id: h.id,
        title: h.title,
        streak: h.streak,
        time: h.time,
        isDone: h.isDone,
        typeIndex: h.typeIndex,
        iconEmoji: h.iconEmoji,
        repeatDays: h.repeatDays,
        startDate: h.startDate,
        orderIndex: i,
      );
      final hiveIndex = box.values.toList().indexWhere((dbH) => dbH.id == h.id);
      if (hiveIndex != -1) {
        await box.putAt(hiveIndex, model);
      }
    }
  }

  Color _getIconBgColor(int typeIndex) {
    switch (typeIndex) {
      case 0: return AppColors.habitBgOrange;
      case 1: return AppColors.habitBgGreen;
      case 2: return AppColors.habitBgPink;
      default: return AppColors.habitBgOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
        title: const Text(
          'All Habits',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_allHabits.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Long press and drag to reorder',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Expanded(
              child: _allHabits.isEmpty
                  ? const Center(
                      child: Text(
                        'No habits found',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _allHabits.length,
                      onReorder: _onReorder,
                      proxyDecorator: (child, index, animation) => child,
                      itemBuilder: (context, index) {
                  final habit = _allHabits[index];
                  
                  return GestureDetector(
                    key: ValueKey(habit.id),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewHabitScreen(editingHabit: habit),
                        ),
                      );
                      _loadHabits();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _getIconBgColor(habit.typeIndex),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                habit.iconEmoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      habit.streak,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      habit.time,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
