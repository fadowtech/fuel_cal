// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Service _$ServiceFromJson(Map<String, dynamic> json) => _Service(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  vehicleId: (json['vehicle_id'] as num?)?.toInt(),
  category: json['category'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ServiceToJson(_Service instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'vehicle_id': instance.vehicleId,
  'category': instance.category,
  'title': instance.title,
  'amount': instance.amount,
  'date': instance.date?.toIso8601String(),
  'notes': instance.notes,
};
