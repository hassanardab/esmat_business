// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 2;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String?,
      projectId: fields[1] as String,
      vendorId: fields[2] as String,
      title: fields[3] as String,
      amount: fields[4] as double,
      status: fields[5] as BillStatus,
      issueDate: fields[6] as DateTime?,
      dueDate: fields[7] as DateTime,
      description: fields[8] as String?,
      paymentMethod: fields[9] as PaymentMethod?,
      paymentDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.vendorId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.issueDate)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.paymentDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
