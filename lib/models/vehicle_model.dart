import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    required String make,
    required String model,
    required int year,
    @JsonKey(name: 'fuel_type') required String fuelType,
    @JsonKey(name: 'tank_capacity') required double tankCapacity,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
