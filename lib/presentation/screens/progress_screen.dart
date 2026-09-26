import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<HabitModel> _habits = [];
  int totalPoints = 0;
  int completedHabits = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final habitsBox = Hive.box<HabitModel>('habits');
    _habits = habitsBox.values.toList();
    
    for (var habit in _habits) {
      if (habit.isDone) {
        completedHabits++;
        totalPoints += 50; 
      }
    }
    setState(() {});
  }

  Color _getColorForType(int typeIndex) {
    switch (typeIndex) {
      case 0: return AppColors.chartDrink;
      case 1: return AppColors.chartMeditation;
      case 2: return AppColors.chartRunning;
      case 3: return AppColors.chartWalking;
      default: return AppColors.chartWalking;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              Expanded(
                child: _habits.isEmpty
                    ? const Center(child: Text('No habits to show', style: TextStyle(color: AppColors.textSecondary)))
                    : _buildChart(),
              ),
              const SizedBox(height: 32),
              _buildPointsSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing progress...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Share Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            'Your progress\nand insights',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
              height: 1.1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: const Icon(Icons.close_rounded, color: AppColors.textMain),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        final isDone = habit.isDone;
        
        // Show 100% if done, or a tiny sliver (5%) if not done
        final percent = isDone ? '100%' : '0%';
        final fillFraction = isDone ? 1.0 : 0.05;
        final color = _getColorForType(habit.typeIndex);

        // Truncate very long habit names for the label
        String label = habit.title;
        if (label.length > 10) {
          label = '${label.substring(0, 8)}..';
        }

        return Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: _buildBar(label, percent, fillFraction, color, habit.iconEmoji),
        );
      },
    );
  }

  Widget _buildBar(String label, String percent, double fillFraction, Color color, String emoji) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.5),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.5),
                    child: CustomPaint(
                      painter: StripesPainter(color: AppColors.chartBgStripes),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: fillFraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(32.5),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  child: Text(
                    percent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$emoji $label',
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Points Earned',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'For this week',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalPoints',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.buttonOrange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Points',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Habits Done', '$completedHabits'),
              _buildStatItem('Total Habits', '${_habits.length}'),
              _buildStatItem('Completion', _habits.isEmpty ? '0%' : '${((completedHabits / _habits.length) * 100).round()}%'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }
}

class StripesPainter extends CustomPainter {
  final Color color;

  StripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double spacing = 8;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
