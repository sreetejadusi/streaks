import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/backup_service.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/toggle_habit_status.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/datasources/habit_local_data_source.dart';
import '../../data/models/profile_model.dart';
import 'new_habit_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'all_habits_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final GetHabits getHabits;
  late final ToggleHabitStatus toggleHabitStatus;
  
  List<Habit> _habits = [];
  bool _isLoading = true;
  bool _hasNotificationPermission = true;
  String _userName = 'Budi';

  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    final dataSource = HabitLocalDataSourceImpl();
    final repository = HabitRepositoryImpl(dataSource);
    getHabits = GetHabits(repository);
    toggleHabitStatus = ToggleHabitStatus(repository);
    
    _loadProfile();
    _loadHabits();
    _checkPermissions();
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final profileBox = Hive.box<ProfileModel>('profile');
    if (profileBox.isNotEmpty) {
      final profile = profileBox.get('user') ?? profileBox.values.first;
      setState(() {
        _userName = profile.name;
      });
    }
  }

  Future<void> _checkPermissions() async {
    final hasPerm = await NotificationService().checkPermission();
    setState(() {
      _hasNotificationPermission = hasPerm;
    });

    if (!hasPerm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionDialog();
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Stay on track with your daily routines by enabling notifications. We will remind you at the right time!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final granted = await NotificationService().requestPermission();
              setState(() {
                _hasNotificationPermission = granted;
              });
            },
            child: const Text('Enable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHabits() async {
    final habits = await getHabits();
    
    final dayIndex = _selectedDate.weekday - 1; 
    final selectedStartOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    setState(() {
      final unsortedHabits = habits.where((h) {
        final habitStart = DateTime.fromMillisecondsSinceEpoch(h.startDate);
        final habitStartOfDay = DateTime(habitStart.year, habitStart.month, habitStart.day);
        
        final isAfterOrSameDay = !selectedStartOfDay.isBefore(habitStartOfDay);
        final isRepeating = h.repeatDays.contains(dayIndex);
        
        return isAfterOrSameDay && isRepeating;
      }).toList();
      
      unsortedHabits.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      _habits = unsortedHabits;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabit(Habit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    if (selected.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot mark habits for future dates!')),
      );
      return;
    }

    final dateStr = "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
    await toggleHabitStatus(habit, dateStr);
    _loadHabits(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildCalendar(),
              const SizedBox(height: 24),
              if (!_hasNotificationPermission) _buildReminderCard(),
              if (!_hasNotificationPermission) const SizedBox(height: 32),
              _buildRoutineHeader(),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _habits.isEmpty 
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              "No habits yet. Tap + to add one!", 
                              style: TextStyle(color: AppColors.textSecondary)
                            ),
                          )
                        )
                      : _buildRoutineList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewHabitScreen()),
          );
          _loadHabits(); 
        },
        backgroundColor: AppColors.buttonDark,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, $_userName',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM, yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE9B6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: SvgPicture.asset('assets/images/avatar.svg', width: 50, height: 50),
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToCenter(int index) {
    if (!_scrollController.hasClients) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    // ListView is inside SingleChildScrollView with 24 horizontal padding on each side
    final viewportWidth = screenWidth - 48.0; 
    const itemWidth = 60.0; // 40 width + 20 margin

    double offset = (index * itemWidth) - (viewportWidth / 2) + (itemWidth / 2);
    offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    // Start from 3 days ago, show 30 days total
    final startDate = now.subtract(const Duration(days: 3));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          bool isSelected = date.day == _selectedDate.day && 
                            date.month == _selectedDate.month && 
                            date.year == _selectedDate.year;
          bool isToday = date.day == now.day && 
                         date.month == now.month && 
                         date.year == now.year;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _scrollToCenter(index);
              _loadHabits();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3), // Mon, Tue, etc
                    style: TextStyle(
                      color: isSelected ? AppColors.textMain : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textMain : Colors.white,
                      shape: BoxShape.circle,
                      border: (!isSelected && isToday) ? Border.all(color: AppColors.buttonOrange, width: 2) : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.textMain.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : (!isSelected && isToday ? AppColors.buttonOrange : AppColors.textMain),
                          fontSize: 15,
                          fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.peachCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Allow Notifications',
                  style: TextStyle(
                    color: AppColors.peachCardText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Never miss your morning routine!\nSet a reminder to stay on track',
                  style: TextStyle(
                    color: AppColors.peachCardText.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final granted = await NotificationService().requestPermission();
                    setState(() {
                      _hasNotificationPermission = granted;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.buttonDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Set Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SvgPicture.asset(
            'assets/images/bell.svg',
            width: 80,
            height: 80,
          )
        ],
      ),
    );
  }

  Widget _buildRoutineHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Daily routine',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllHabitsScreen()),
            ).then((_) => _loadHabits());
          },
          child: Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.buttonDark.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineList() {
    return Column(
      children: _habits.asMap().entries.map((entry) {
        final index = entry.key;
        final habit = entry.value;
        
        IconData iconData;
        Color iconBgColor;
        Color iconColor;
        
        switch (habit.typeIndex) {
          case 0:
            iconData = Icons.local_drink_rounded;
            iconBgColor = AppColors.habitBgOrange;
            iconColor = AppColors.habitIconOrange;
            break;
          case 1:
            iconData = Icons.self_improvement_rounded;
            iconBgColor = AppColors.habitBgGreen;
            iconColor = AppColors.habitIconGreen;
            break;
          case 2:
            iconData = Icons.accessibility_new_rounded;
            iconBgColor = AppColors.habitBgPink;
            iconColor = AppColors.habitIconPink;
            break;
          default:
            iconData = Icons.directions_walk_rounded;
            iconBgColor = AppColors.habitBgOrange;
            iconColor = AppColors.habitIconOrange;
        }

        final dateStr = "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";
        final isCompleted = habit.completedDates.contains(dateStr);

        return GestureDetector(
          onTap: () => _toggleHabit(habit),
          onLongPress: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewHabitScreen(editingHabit: habit),
              ),
            );
            _loadHabits();
          },
          child: _buildRoutineItem(
            isFirst: index == 0,
            isLast: index == _habits.length - 1,
            isDone: isCompleted,
            title: habit.title,
            streak: habit.streak,
            time: habit.time,
            iconEmoji: habit.iconEmoji,
            iconBgColor: iconBgColor,
            iconColor: iconColor,
            hideTime: habit.typeIndex == 3,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoutineItem({
    required bool isFirst,
    required bool isLast,
    required bool isDone,
    required String title,
    required String streak,
    required String time,
    required String iconEmoji,
    required Color iconBgColor,
    required Color iconColor,
    bool hideTime = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomPaint(
                    painter: DottedLinePainter(
                      color: isFirst ? Colors.transparent : Colors.grey.shade300,
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.buttonOrange : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? AppColors.buttonOrange : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                Expanded(
                  flex: 1,
                  child: CustomPaint(
                    painter: DottedLinePainter(
                      color: isLast ? Colors.transparent : Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        iconEmoji, 
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streak,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!hideTime) ...[
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 16),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (color == Colors.transparent) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    double dashHeight = 4, dashSpace = 4, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
