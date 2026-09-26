import 'package:hive/hive.dart';
import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.title,
    required super.streak,
    required super.time,
    required super.isDone,
    super.completedDates = const [],
    required super.typeIndex,
    super.iconEmoji = '🎯',
    super.repeatDays = const [0, 1, 2, 3, 4, 5, 6],
    super.startDate = 0,
    super.orderIndex = 0,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      title: json['title'],
      streak: json['streak'],
      time: json['time'],
      isDone: json['isDone'],
      completedDates: List<String>.from(json['completedDates'] ?? []),
      typeIndex: json['typeIndex'],
      iconEmoji: json['iconEmoji'] ?? '🎯',
      repeatDays: List<int>.from(json['repeatDays'] ?? [0, 1, 2, 3, 4, 5, 6]),
      startDate: json['startDate'] ?? 0,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'streak': streak,
      'time': time,
      'isDone': isDone,
      'completedDates': completedDates,
      'typeIndex': typeIndex,
      'iconEmoji': iconEmoji,
      'repeatDays': repeatDays,
      'startDate': startDate,
      'orderIndex': orderIndex,
    };
  }
}

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    String id = reader.readString();
    String title = reader.readString();
    String streak = reader.readString();
    String time = reader.readString();
    bool isDone = reader.readBool();
    int typeIndex = reader.readInt();
    
    String emoji = '🎯';
    List<int> rDays = [0, 1, 2, 3, 4, 5, 6];
    int sDate = 0;
    int oIndex = 0;
    List<String> cDates = [];
    
    try {
      if (reader.availableBytes > 0) emoji = reader.readString();
      if (reader.availableBytes > 0) rDays = reader.readList().cast<int>();
      if (reader.availableBytes > 0) sDate = reader.readInt();
      if (reader.availableBytes > 0) oIndex = reader.readInt();
      
      if (reader.availableBytes > 0) cDates = reader.readList().cast<String>();
    } catch (e) {
      // Ignored for backwards compatibility
    }

    return HabitModel(
      id: id,
      title: title,
      streak: streak,
      time: time,
      isDone: isDone,
      typeIndex: typeIndex,
      iconEmoji: emoji,
      repeatDays: rDays,
      startDate: sDate,
      orderIndex: oIndex,
      completedDates: cDates,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.streak);
    writer.writeString(obj.time);
    writer.writeBool(obj.isDone);
    writer.writeInt(obj.typeIndex);
    writer.writeString(obj.iconEmoji);
    writer.writeList(obj.repeatDays);
    writer.writeInt(obj.startDate);
    writer.writeInt(obj.orderIndex);
    writer.writeList(obj.completedDates);
  }
}
