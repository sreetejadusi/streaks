import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/habit.dart';
import 'package:hive/hive.dart';
import '../../data/models/habit_model.dart';
import '../../domain/usecases/add_habit.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/datasources/habit_local_data_source.dart';

class NewHabitScreen extends StatefulWidget {
  final Habit? editingHabit;
  const NewHabitScreen({super.key, this.editingHabit});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  bool _getReminders = false;
  List<int> _selectedDays = [0, 1, 2, 3, 4, 5, 6]; 
  String _selectedAmount = '10 min';
  int _selectedTypeIndex = 1; 
  String _selectedEmoji = '🎯';
  String _startDateText = 'Start date';
  DateTime _selectedStartDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  

  late final AddHabit addHabit;

  @override
  void initState() {
    super.initState();
    final dataSource = HabitLocalDataSourceImpl();
    final repository = HabitRepositoryImpl(dataSource);
    addHabit = AddHabit(repository);
    
    if (widget.editingHabit != null) {
      _titleController.text = widget.editingHabit!.title;
      _selectedAmount = widget.editingHabit!.time;
      _selectedTypeIndex = widget.editingHabit!.typeIndex;
      _selectedEmoji = widget.editingHabit!.iconEmoji;
      _selectedDays = List<int>.from(widget.editingHabit!.repeatDays);
      _selectedStartDate = DateTime.fromMillisecondsSinceEpoch(widget.editingHabit!.startDate);
      _startDateText = DateFormat('MMM d, yyyy').format(_selectedStartDate);
    }
    
  }

  @override
  void dispose() {
    _titleController.dispose();
    
    super.dispose();
  }

  Future<void> _saveHabit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }
      
    final habit = Habit(
      id: widget.editingHabit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      streak: widget.editingHabit?.streak ?? 'Streak 0 days',
      time: _selectedAmount,
      isDone: widget.editingHabit?.isDone ?? false,
      typeIndex: _selectedTypeIndex, 
      iconEmoji: _selectedEmoji,
      repeatDays: _selectedDays,
      startDate: _selectedStartDate.millisecondsSinceEpoch,
    );

    final box = Hive.box<HabitModel>('habits');
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
    );
    
    if (widget.editingHabit != null) {
      // Find index and update
      final index = box.values.toList().indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        await box.putAt(index, model);
      }
    } else {
      await addHabit(habit);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showAmountPicker() {
    final hController = TextEditingController();
    final mController = TextEditingController();
    
    // Basic parse of current _selectedAmount if we want to prefill
    // For simplicity, leave empty.

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24, left: 24, right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Hours (1-12)',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.buttonOrange, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: mController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Minutes (1-60)',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.buttonOrange, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    int finalH = int.tryParse(hController.text) ?? 0;
                    int finalM = int.tryParse(mController.text) ?? 0;
                    
                    if (finalH > 12) finalH = 12;
                    if (finalM > 60) finalM = 60;
                    
                    String res = '';
                    if (finalH > 0) res += '${finalH} hr ';
                    if (finalM > 0) res += '${finalM} min';
                    if (res.isEmpty) res = '15 min';
                    
                    setState(() {
                      _selectedAmount = res.trim();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

    void _deleteHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Habit', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to delete this habit? All completion history will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final box = Hive.box<HabitModel>('habits');
              await box.delete(widget.editingHabit!.id);
              if (mounted) {
                Navigator.pop(context); // pop dialog
                Navigator.pop(context); // pop screen
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    final List<String> popularEmojis = [
      '🎯', '💧', '🧘', '🏃', '🚶', '📚', '💪', '🍎', 
      '💤', '📝', '🎨', '🎸', '💻', '🧹', '🪴', '💰',
      '💊', '🔥', '🧠', '🎧', '🏋️', '🍳', '💵', '🛁'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select an Icon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: popularEmojis.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() {
        _selectedStartDate = date;
        _startDateText = DateFormat('MMM d, yyyy').format(date);
      });
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
              const SizedBox(height: 30),
              Center(
                child: _buildIllustration(),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Name your habit'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showEmojiPicker,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  _selectedEmoji,
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField('e.g. Morning Meditations'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildLabel('Set a goal'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownLikeButton(_startDateText, Icons.calendar_today_rounded, onTap: _showDatePicker),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownLikeButton(_selectedAmount, Icons.keyboard_arrow_down_rounded, isTrailing: true, onTap: _showAmountPicker),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Repeat days'),
                      const SizedBox(height: 4),
                      Text(
                        _getRepeatSubtitle(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDaysRow(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Get reminders'),
                          Switch(
                            value: _getReminders,
                            onChanged: (val) {
                              setState(() {
                                _getReminders = val;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: AppColors.buttonOrange,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade300,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.editingHabit != null ? 'Update Habit' : 'Save Habit',
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
      children: [
        Text(
          widget.editingHabit != null ? 'Edit habit' : 'New habit',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        Row(
          children: [
            if (widget.editingHabit != null)
              GestureDetector(
                onTap: _deleteHabit,
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
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
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SvgPicture.asset(
      'assets/images/calendar.svg',
      width: 120,
      height: 120,
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
    );
  }



  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }



  Widget _buildDropdownLikeButton(String text, IconData icon, {bool isTrailing = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: isTrailing ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            if (!isTrailing) ...[
              Text(
                text,
                style: TextStyle(
                  color: text == 'Start date' ? Colors.grey.shade400 : AppColors.textMain,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Icon(icon, color: Colors.grey.shade400, size: 20),
            ],
            if (isTrailing) ...[
              Text(
                text,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              Icon(icon, color: AppColors.textMain, size: 20),
            ]
          ],
        ),
      ),
    );
  }

  String _getRepeatSubtitle() {
    if (_selectedDays.isEmpty) return 'No days selected';
    if (_selectedDays.length == 7) return 'Every Day';
    
    final weekdays = [0, 1, 2, 3, 4];
    final weekends = [5, 6];
    
    bool hasAllWeekdays = weekdays.every((d) => _selectedDays.contains(d));
    bool hasAllWeekends = weekends.every((d) => _selectedDays.contains(d));
    bool hasNoWeekdays = weekdays.every((d) => !_selectedDays.contains(d));
    bool hasNoWeekends = weekends.every((d) => !_selectedDays.contains(d));
    
    if (hasAllWeekdays && hasNoWeekends) return 'Every Day Except Weekends';
    if (hasAllWeekends && hasNoWeekdays) return 'Weekends only';
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = _selectedDays.toList()..sort();
    return sortedDays.map((d) => dayNames[d]).join(', ');
  }

  Widget _buildDaysRow() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        bool isSelected = _selectedDays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.textMain : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
