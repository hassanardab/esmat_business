import 'package:esmat_business/models/enums.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'payroll.g.dart';

@HiveType(typeId: 3)
class Payroll {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String employeeName;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  PaymentMethod paymentMethod;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  bool isPaid;

  Payroll({
    String? id,
    required this.projectId,
    required this.employeeName,
    required this.amount,
    DateTime? date,
    this.paymentMethod = PaymentMethod.cash,
    this.description,
    this.isPaid = false,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  bool get isCash => paymentMethod == PaymentMethod.cash;
  bool get isBank => paymentMethod == PaymentMethod.bankTransfer;

  Payroll.copy(Payroll other)
    : this(
        id: other.id,
        projectId: other.projectId,
        employeeName: other.employeeName,
        amount: other.amount,
        date: other.date,
        paymentMethod: other.paymentMethod,
        description: other.description,
        isPaid: other.isPaid,
      );
}
