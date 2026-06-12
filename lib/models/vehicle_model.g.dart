// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vehicle _$VehicleFromJson(Map<String, dynamic> json) => _Vehicle(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  make: json['make'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  fuelType: json['fuel_type'] as String,
  tankCapacity: (json['tank_capacity'] as num).toDouble(),
  vehicleNumber: json['vehicle_number'] as String?,
  variant: json['variant'] as String?,
  vehicleType: json['vehicle_type'] as String?,
  tankType: json['tank_type'] as String?,
  highestAvgMileage: (json['highest_avg_mileage'] as num?)?.toDouble(),
  avgMileage: (json['avg_mileage'] as num?)?.toDouble(),
  poorMileage: (json['poor_mileage'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  color: json['color'] as String?,
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$VehicleToJson(_Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'make': instance.make,
  'model': instance.model,
  'year': instance.year,
  'fuel_type': instance.fuelType,
  'tank_capacity': instance.tankCapacity,
  'vehicle_number': instance.vehicleNumber,
  'variant': instance.variant,
  'vehicle_type': instance.vehicleType,
  'tank_type': instance.tankType,
  'highest_avg_mileage': instance.highestAvgMileage,
  'avg_mileage': instance.avgMileage,
  'poor_mileage': instance.poorMileage,
  'notes': instance.notes,
  'color': instance.color,
  'is_default': instance.isDefault,
};
