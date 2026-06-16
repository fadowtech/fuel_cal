// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FuelLog _$FuelLogFromJson(Map<String, dynamic> json) => _FuelLog(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  vehicleId: (json['vehicle_id'] as num?)?.toInt(),
  odometer: (json['odometer'] as num).toDouble(),
  fuelQuantity: (json['fuel_quantity'] as num).toDouble(),
  totalCost: (json['total_cost'] as num).toDouble(),
  stationName: json['station_name'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  fuelPrice: (json['fuel_price'] as num?)?.toDouble(),
  remainingRange: (json['remaining_range'] as num?)?.toDouble(),
  remainingRangeAfter: (json['remaining_range_after'] as num?)?.toDouble(),
  isFullTank: json['is_full_tank'] as bool? ?? false,
  missedFillup: json['missed_fillup'] as bool? ?? false,
  location: json['location'] as String?,
  notes: json['notes'] as String?,
  paymentMethod: json['payment_method'] as String?,
  billImagePath: json['bill_image_path'] as String?,
);

Map<String, dynamic> _$FuelLogToJson(_FuelLog instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'vehicle_id': instance.vehicleId,
  'odometer': instance.odometer,
  'fuel_quantity': instance.fuelQuantity,
  'total_cost': instance.totalCost,
  'station_name': instance.stationName,
  'date': instance.date?.toIso8601String(),
  'fuel_price': instance.fuelPrice,
  'remaining_range': instance.remainingRange,
  'remaining_range_after': instance.remainingRangeAfter,
  'is_full_tank': instance.isFullTank,
  'missed_fillup': instance.missedFillup,
  'location': instance.location,
  'notes': instance.notes,
  'payment_method': instance.paymentMethod,
  'bill_image_path': instance.billImagePath,
};
