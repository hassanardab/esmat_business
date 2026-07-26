import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final PaymentMethod paymentMethod;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? category;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? vendorId;

  Transaction({
    String? id,
    required this.projectId,
    required this.title,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    DateTime? date,
    this.category,
    this.description,
    this.vendorId,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  // For balance calculations
  bool get isCash => paymentMethod == PaymentMethod.cash;
  bool get isBank => paymentMethod == PaymentMethod.bankTransfer;
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Transaction.copy(Transaction other)
    : this(
        id: other.id,
        projectId: other.projectId,
        title: other.title,
        amount: other.amount,
        type: other.type,
        paymentMethod: other.paymentMethod,
        date: other.date,
        category: other.category,
        description: other.description,
        vendorId: other.vendorId,
      );
}
