// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return _Vehicle.fromJson(json);
}

/// @nodoc
mixin _$Vehicle {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  String get make => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  @JsonKey(name: 'fuel_type')
  String get fuelType => throw _privateConstructorUsedError;
  @JsonKey(name: 'tank_capacity')
  double get tankCapacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_number')
  String? get vehicleNumber => throw _privateConstructorUsedError;
  String? get variant => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_type')
  String? get vehicleType => throw _privateConstructorUsedError;
  @JsonKey(name: 'tank_type')
  String? get tankType => throw _privateConstructorUsedError;
  @JsonKey(name: 'highest_avg_mileage')
  double? get highestAvgMileage => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_mileage')
  double? get avgMileage => throw _privateConstructorUsedError;
  @JsonKey(name: 'poor_mileage')
  double? get poorMileage => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleCopyWith<Vehicle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) then) =
      _$VehicleCopyWithImpl<$Res, Vehicle>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      String make,
      String model,
      int year,
      @JsonKey(name: 'fuel_type') String fuelType,
      @JsonKey(name: 'tank_capacity') double tankCapacity,
      @JsonKey(name: 'vehicle_number') String? vehicleNumber,
      String? variant,
      @JsonKey(name: 'vehicle_type') String? vehicleType,
      @JsonKey(name: 'tank_type') String? tankType,
      @JsonKey(name: 'highest_avg_mileage') double? highestAvgMileage,
      @JsonKey(name: 'avg_mileage') double? avgMileage,
      @JsonKey(name: 'poor_mileage') double? poorMileage,
      String? notes,
      String? color});
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res, $Val extends Vehicle>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? fuelType = null,
    Object? tankCapacity = null,
    Object? vehicleNumber = freezed,
    Object? variant = freezed,
    Object? vehicleType = freezed,
    Object? tankType = freezed,
    Object? highestAvgMileage = freezed,
    Object? avgMileage = freezed,
    Object? poorMileage = freezed,
    Object? notes = freezed,
    Object? color = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      fuelType: null == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String,
      tankCapacity: null == tankCapacity
          ? _value.tankCapacity
          : tankCapacity // ignore: cast_nullable_to_non_nullable
              as double,
      vehicleNumber: freezed == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      variant: freezed == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleType: freezed == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String?,
      tankType: freezed == tankType
          ? _value.tankType
          : tankType // ignore: cast_nullable_to_non_nullable
              as String?,
      highestAvgMileage: freezed == highestAvgMileage
          ? _value.highestAvgMileage
          : highestAvgMileage // ignore: cast_nullable_to_non_nullable
              as double?,
      avgMileage: freezed == avgMileage
          ? _value.avgMileage
          : avgMileage // ignore: cast_nullable_to_non_nullable
              as double?,
      poorMileage: freezed == poorMileage
          ? _value.poorMileage
          : poorMileage // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleImplCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$$VehicleImplCopyWith(
          _$VehicleImpl value, $Res Function(_$VehicleImpl) then) =
      __$$VehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      String make,
      String model,
      int year,
      @JsonKey(name: 'fuel_type') String fuelType,
      @JsonKey(name: 'tank_capacity') double tankCapacity,
      @JsonKey(name: 'vehicle_number') String? vehicleNumber,
      String? variant,
      @JsonKey(name: 'vehicle_type') String? vehicleType,
      @JsonKey(name: 'tank_type') String? tankType,
      @JsonKey(name: 'highest_avg_mileage') double? highestAvgMileage,
      @JsonKey(name: 'avg_mileage') double? avgMileage,
      @JsonKey(name: 'poor_mileage') double? poorMileage,
      String? notes,
      String? color});
}

/// @nodoc
class __$$VehicleImplCopyWithImpl<$Res>
    extends _$VehicleCopyWithImpl<$Res, _$VehicleImpl>
    implements _$$VehicleImplCopyWith<$Res> {
  __$$VehicleImplCopyWithImpl(
      _$VehicleImpl _value, $Res Function(_$VehicleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? fuelType = null,
    Object? tankCapacity = null,
    Object? vehicleNumber = freezed,
    Object? variant = freezed,
    Object? vehicleType = freezed,
    Object? tankType = freezed,
    Object? highestAvgMileage = freezed,
    Object? avgMileage = freezed,
    Object? poorMileage = freezed,
    Object? notes = freezed,
    Object? color = freezed,
  }) {
    return _then(_$VehicleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      fuelType: null == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String,
      tankCapacity: null == tankCapacity
          ? _value.tankCapacity
          : tankCapacity // ignore: cast_nullable_to_non_nullable
              as double,
      vehicleNumber: freezed == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      variant: freezed == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleType: freezed == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String?,
      tankType: freezed == tankType
          ? _value.tankType
          : tankType // ignore: cast_nullable_to_non_nullable
              as String?,
      highestAvgMileage: freezed == highestAvgMileage
          ? _value.highestAvgMileage
          : highestAvgMileage // ignore: cast_nullable_to_non_nullable
              as double?,
      avgMileage: freezed == avgMileage
          ? _value.avgMileage
          : avgMileage // ignore: cast_nullable_to_non_nullable
              as double?,
      poorMileage: freezed == poorMileage
          ? _value.poorMileage
          : poorMileage // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleImpl implements _Vehicle {
  const _$VehicleImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.make,
      required this.model,
      required this.year,
      @JsonKey(name: 'fuel_type') required this.fuelType,
      @JsonKey(name: 'tank_capacity') required this.tankCapacity,
      @JsonKey(name: 'vehicle_number') this.vehicleNumber,
      this.variant,
      @JsonKey(name: 'vehicle_type') this.vehicleType,
      @JsonKey(name: 'tank_type') this.tankType,
      @JsonKey(name: 'highest_avg_mileage') this.highestAvgMileage,
      @JsonKey(name: 'avg_mileage') this.avgMileage,
      @JsonKey(name: 'poor_mileage') this.poorMileage,
      this.notes,
      this.color});

  factory _$VehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  final String make;
  @override
  final String model;
  @override
  final int year;
  @override
  @JsonKey(name: 'fuel_type')
  final String fuelType;
  @override
  @JsonKey(name: 'tank_capacity')
  final double tankCapacity;
  @override
  @JsonKey(name: 'vehicle_number')
  final String? vehicleNumber;
  @override
  final String? variant;
  @override
  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;
  @override
  @JsonKey(name: 'tank_type')
  final String? tankType;
  @override
  @JsonKey(name: 'highest_avg_mileage')
  final double? highestAvgMileage;
  @override
  @JsonKey(name: 'avg_mileage')
  final double? avgMileage;
  @override
  @JsonKey(name: 'poor_mileage')
  final double? poorMileage;
  @override
  final String? notes;
  @override
  final String? color;

  @override
  String toString() {
    return 'Vehicle(id: $id, userId: $userId, make: $make, model: $model, year: $year, fuelType: $fuelType, tankCapacity: $tankCapacity, vehicleNumber: $vehicleNumber, variant: $variant, vehicleType: $vehicleType, tankType: $tankType, highestAvgMileage: $highestAvgMileage, avgMileage: $avgMileage, poorMileage: $poorMileage, notes: $notes, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.tankCapacity, tankCapacity) ||
                other.tankCapacity == tankCapacity) &&
            (identical(other.vehicleNumber, vehicleNumber) ||
                other.vehicleNumber == vehicleNumber) &&
            (identical(other.variant, variant) || other.variant == variant) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.tankType, tankType) ||
                other.tankType == tankType) &&
            (identical(other.highestAvgMileage, highestAvgMileage) ||
                other.highestAvgMileage == highestAvgMileage) &&
            (identical(other.avgMileage, avgMileage) ||
                other.avgMileage == avgMileage) &&
            (identical(other.poorMileage, poorMileage) ||
                other.poorMileage == poorMileage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      make,
      model,
      year,
      fuelType,
      tankCapacity,
      vehicleNumber,
      variant,
      vehicleType,
      tankType,
      highestAvgMileage,
      avgMileage,
      poorMileage,
      notes,
      color);

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      __$$VehicleImplCopyWithImpl<_$VehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleImplToJson(
      this,
    );
  }
}

abstract class _Vehicle implements Vehicle {
  const factory _Vehicle(
      {required final int id,
      @JsonKey(name: 'user_id') required final int userId,
      required final String make,
      required final String model,
      required final int year,
      @JsonKey(name: 'fuel_type') required final String fuelType,
      @JsonKey(name: 'tank_capacity') required final double tankCapacity,
      @JsonKey(name: 'vehicle_number') final String? vehicleNumber,
      final String? variant,
      @JsonKey(name: 'vehicle_type') final String? vehicleType,
      @JsonKey(name: 'tank_type') final String? tankType,
      @JsonKey(name: 'highest_avg_mileage') final double? highestAvgMileage,
      @JsonKey(name: 'avg_mileage') final double? avgMileage,
      @JsonKey(name: 'poor_mileage') final double? poorMileage,
      final String? notes,
      final String? color}) = _$VehicleImpl;

  factory _Vehicle.fromJson(Map<String, dynamic> json) = _$VehicleImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  String get make;
  @override
  String get model;
  @override
  int get year;
  @override
  @JsonKey(name: 'fuel_type')
  String get fuelType;
  @override
  @JsonKey(name: 'tank_capacity')
  double get tankCapacity;
  @override
  @JsonKey(name: 'vehicle_number')
  String? get vehicleNumber;
  @override
  String? get variant;
  @override
  @JsonKey(name: 'vehicle_type')
  String? get vehicleType;
  @override
  @JsonKey(name: 'tank_type')
  String? get tankType;
  @override
  @JsonKey(name: 'highest_avg_mileage')
  double? get highestAvgMileage;
  @override
  @JsonKey(name: 'avg_mileage')
  double? get avgMileage;
  @override
  @JsonKey(name: 'poor_mileage')
  double? get poorMileage;
  @override
  String? get notes;
  @override
  String? get color;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
