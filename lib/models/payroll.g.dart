// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PayrollAdapter extends TypeAdapter<Payroll> {
  @override
  final int typeId = 3;

  @override
  Payroll read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payroll(
      id: fields[0] as String?,
      projectId: fields[1] as String,
      employeeName: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime?,
      paymentMethod: fields[5] as PaymentMethod,
      description: fields[6] as String?,
      isPaid: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Payroll obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.employeeName)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.isPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayrollAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
