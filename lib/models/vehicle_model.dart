import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

@freezed
abstract class Vehicle with _$Vehicle {
  const factory Vehicle({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    required String make,
    required String model,
    required int year,
    @JsonKey(name: 'fuel_type') required String fuelType,
    @JsonKey(name: 'tank_capacity') required double tankCapacity,
    @JsonKey(name: 'vehicle_number') String? vehicleNumber,
    String? variant,
    @JsonKey(name: 'vehicle_type') String? vehicleType,
    @JsonKey(name: 'tank_type') String? tankType,
    @JsonKey(name: 'highest_avg_mileage') double? highestAvgMileage,
    @JsonKey(name: 'avg_mileage') double? avgMileage,
    @JsonKey(name: 'poor_mileage') double? poorMileage,
    String? notes,
    String? color,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
