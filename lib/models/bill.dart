import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'bill.g.dart';

@HiveType(typeId: 2)
class Bill {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String vendorId;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  BillStatus status;

  @HiveField(6)
  final DateTime issueDate;

  @HiveField(7)
  final DateTime dueDate;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  PaymentMethod? paymentMethod;

  @HiveField(10)
  DateTime? paymentDate;

  Bill({
    String? id,
    required this.projectId,
    required this.vendorId,
    required this.title,
    required this.amount,
    this.status = BillStatus.pending,
    DateTime? issueDate,
    required this.dueDate,
    this.description,
    this.paymentMethod,
    this.paymentDate,
  }) : id = id ?? const Uuid().v4(),
       issueDate = issueDate ?? DateTime.now();

  bool get isPaid => status == BillStatus.paid;
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  Bill.copy(Bill other)
    : this(
        id: other.id,
        projectId: other.projectId,
        vendorId: other.vendorId,
        title: other.title,
        amount: other.amount,
        status: other.status,
        issueDate: other.issueDate,
        dueDate: other.dueDate,
        description: other.description,
        paymentMethod: other.paymentMethod,
        paymentDate: other.paymentDate,
      );
}
