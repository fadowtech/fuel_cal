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
    @JsonKey(name: 'station_name') String? stationName,
    DateTime? date,
    @JsonKey(name: 'fuel_price') double? fuelPrice,
    @JsonKey(name: 'remaining_range') double? remainingRange,
    @JsonKey(name: 'remaining_range_after') double? remainingRangeAfter,
    @JsonKey(name: 'is_full_tank') @Default(false) bool isFullTank,
    String? location,
    String? notes,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'bill_image_path') String? billImagePath,
  }) = _FuelLog;

  factory FuelLog.fromJson(Map<String, dynamic> json) => _$FuelLogFromJson(json);
}
