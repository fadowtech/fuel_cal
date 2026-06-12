import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_model.freezed.dart';
part 'service_model.g.dart';

@freezed
abstract class Service with _$Service {
  const factory Service({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'vehicle_id') int? vehicleId,
    required String category,
    required String title,
    required double amount,
    DateTime? date,
    String? notes,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}
