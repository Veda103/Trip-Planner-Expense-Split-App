// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItineraryItemAdapter extends TypeAdapter<ItineraryItem> {
  @override
  final int typeId = 1;

  @override
  ItineraryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryItem(
      id: fields[0] as String,
      tripId: fields[1] as String,
      date: fields[2] as DateTime,
      time: fields[3] as String?,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
