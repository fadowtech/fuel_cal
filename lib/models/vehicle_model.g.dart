// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      fuelType: json['fuel_type'] as String,
      tankCapacity: (json['tank_capacity'] as num).toDouble(),
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'fuel_type': instance.fuelType,
      'tank_capacity': instance.tankCapacity,
    };
