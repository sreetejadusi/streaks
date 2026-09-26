import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/profile_model.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<String?> exportData() async {
    try {
      final profileBox = Hive.box<ProfileModel>('profile');
      final habitsBox = Hive.box<HabitModel>('habits');

      final profileList = profileBox.values.toList();
      final habitsList = habitsBox.values.toList();

      final data = {
        'profile': profileList.map((e) => e.toJson()).toList(),
        'habits': habitsList.map((e) => e.toJson()).toList(),
      };

      final jsonString = jsonEncode(data);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/Streaks');
      } else if (Platform.isIOS) {
        final docsDir = await getApplicationDocumentsDirectory();
        directory = Directory('${docsDir.path}/Streaks');
      } else {
        final docsDir = await getDownloadsDirectory();
        directory = Directory('${docsDir?.path}/Streaks');
      }

      if (directory != null && !await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.streaks';
      final file = File('${directory?.path}/$fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        final profileBox = Hive.box<ProfileModel>('profile');
        final habitsBox = Hive.box<HabitModel>('habits');

        await profileBox.clear();
        await habitsBox.clear();

        if (data.containsKey('profile')) {
          final profilesList = data['profile'] as List;
          if (profilesList.isNotEmpty) {
            final profile = ProfileModel.fromJson(profilesList.first);
            await profileBox.put('user', profile);
          }
        }

        if (data.containsKey('habits')) {
          final habitsList = data['habits'] as List;
          for (var h in habitsList) {
            final habit = HabitModel.fromJson(h);
            await habitsBox.put(habit.id, habit);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }
}
