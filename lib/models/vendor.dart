import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'vendor.g.dart';

@HiveType(typeId: 4)
class Vendor {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? contact;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  double currentBalance;

  @HiveField(5)
  final String? address;

  @HiveField(6)
  final DateTime createdAt;

  Vendor({
    String? id,
    required this.name,
    this.contact,
    this.email,
    this.currentBalance = 0,
    this.address,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Vendor.copy(Vendor other)
    : this(
        id: other.id,
        name: other.name,
        contact: other.contact,
        email: other.email,
        currentBalance: other.currentBalance,
        address: other.address,
        createdAt: other.createdAt,
      );
}
