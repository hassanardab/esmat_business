//lib/models/project.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double startingCashBalance;

  @HiveField(3)
  final double startingBankBalance;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  String description;

  Project({
    String? id,
    required this.name,
    required this.startingCashBalance,
    required this.startingBankBalance,
    this.description = '',
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  double get totalStartingBalance => startingCashBalance + startingBankBalance;

  // For Hive
  Project.copy(Project other)
    : this(
        id: other.id,
        name: other.name,
        startingCashBalance: other.startingCashBalance,
        startingBankBalance: other.startingBankBalance,
        description: other.description,
        createdAt: other.createdAt,
      );
}
