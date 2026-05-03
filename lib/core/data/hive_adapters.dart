import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/routine/domain/models/task.dart';
import '../../features/pet/domain/models/pet.dart';

class HiveService {
  static const _petDataVersionKey = 'pet_data_version';
  static const _currentPetDataVersion = 1;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(PetAdapter());
  }

  static Box<Task> get tasksBox => Hive.box<Task>('tasks_v2');
  static Box<Pet> get petBox => Hive.box<Pet>('pet');
  static Box<List> get accessoriesBox => Hive.box<List>('accessories');

  static Future<void> openBoxes() async {
    await _migratePetDataIfNeeded();

    await Hive.openBox<Task>('tasks_v2');
    await Hive.openBox<Pet>('pet');
    await Hive.openBox<List>('accessories');
    await Hive.openBox('postponed_tasks');
  }

  static Future<void> _migratePetDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_petDataVersionKey) ?? 0;

    if (savedVersion >= _currentPetDataVersion) return;

    await Hive.deleteBoxFromDisk('pet');

    await prefs.setInt(_petDataVersionKey, _currentPetDataVersion);
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      category: TaskCategory.values[reader.readInt()],
      time: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
      repeatDays: reader.readList().cast<int>(),
      isCompleted: reader.readBool(),
      xpReward: reader.readInt(),
      coinReward: reader.readInt(),
      createdAt: DateTime.parse(reader.readString()),
      completedAt:
          reader.readBool()
              ? DateTime.parse(reader.readString())
              : null,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.category.index);
    writer.writeInt(obj.time.hour);
    writer.writeInt(obj.time.minute);
    writer.writeList(obj.repeatDays);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.xpReward);
    writer.writeInt(obj.coinReward);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeString(obj.completedAt!.toIso8601String());
    }
  }
}

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 2;

  static const int _version = 1;

  @override
  Pet read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != _version) {
      throw StateError('Unsupported Pet data version: $version');
    }
    return Pet(
      petType: PetType.values[reader.readInt()],
      name: reader.readString(),
      level: reader.readInt(),
      currentXp: reader.readInt(),
      xpToNextLevel: reader.readInt(),
      coins: reader.readInt(),
      equippedAccessories: reader.readList().cast<String>(),
      mood: PetMood.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer.writeInt(_version);
    writer.writeInt(obj.petType.index);
    writer.writeString(obj.name);
    writer.writeInt(obj.level);
    writer.writeInt(obj.currentXp);
    writer.writeInt(obj.xpToNextLevel);
    writer.writeInt(obj.coins);
    writer.writeList(obj.equippedAccessories);
    writer.writeInt(obj.mood.index);
  }
}
