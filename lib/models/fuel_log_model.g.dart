// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelLogImpl _$$FuelLogImplFromJson(Map<String, dynamic> json) =>
    _$FuelLogImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      odometer: (json['odometer'] as num).toDouble(),
      fuelQuantity: (json['fuel_quantity'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      stationName: json['station_name'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$FuelLogImplToJson(_$FuelLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'vehicle_id': instance.vehicleId,
      'odometer': instance.odometer,
      'fuel_quantity': instance.fuelQuantity,
      'total_cost': instance.totalCost,
      'station_name': instance.stationName,
      'date': instance.date?.toIso8601String(),
    };
