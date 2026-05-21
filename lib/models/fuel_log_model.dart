import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_log_model.freezed.dart';
part 'fuel_log_model.g.dart';

@freezed
class FuelLog with _$FuelLog {
  const factory FuelLog({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'vehicle_id') int? vehicleId,
    required double odometer,
    @JsonKey(name: 'fuel_quantity') required double fuelQuantity,
    @JsonKey(name: 'total_cost') required double totalCost,
    DateTime? date,
  }) = _FuelLog;

  factory FuelLog.fromJson(Map<String, dynamic> json) => _$FuelLogFromJson(json);
}
