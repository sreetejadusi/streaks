import 'package:hive/hive.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.name,
    required super.age,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 1;

  @override
  ProfileModel read(BinaryReader reader) {
    return ProfileModel(
      name: reader.readString(),
      age: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.age);
  }
}
