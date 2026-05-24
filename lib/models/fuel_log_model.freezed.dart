// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FuelLog _$FuelLogFromJson(Map<String, dynamic> json) {
  return _FuelLog.fromJson(json);
}

/// @nodoc
mixin _$FuelLog {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle_id')
  int? get vehicleId => throw _privateConstructorUsedError;
  double get odometer => throw _privateConstructorUsedError;
  @JsonKey(name: 'fuel_quantity')
  double get fuelQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_cost')
  double get totalCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'station_name')
  String? get stationName => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'fuel_price')
  double? get fuelPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_range')
  double? get remainingRange => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_full_tank')
  bool get isFullTank => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String? get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'bill_image_path')
  String? get billImagePath => throw _privateConstructorUsedError;

  /// Serializes this FuelLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelLogCopyWith<FuelLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelLogCopyWith<$Res> {
  factory $FuelLogCopyWith(FuelLog value, $Res Function(FuelLog) then) =
      _$FuelLogCopyWithImpl<$Res, FuelLog>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'vehicle_id') int? vehicleId,
      double odometer,
      @JsonKey(name: 'fuel_quantity') double fuelQuantity,
      @JsonKey(name: 'total_cost') double totalCost,
      @JsonKey(name: 'station_name') String? stationName,
      DateTime? date,
      @JsonKey(name: 'fuel_price') double? fuelPrice,
      @JsonKey(name: 'remaining_range') double? remainingRange,
      @JsonKey(name: 'is_full_tank') bool isFullTank,
      String? location,
      String? notes,
      @JsonKey(name: 'payment_method') String? paymentMethod,
      @JsonKey(name: 'bill_image_path') String? billImagePath});
}

/// @nodoc
class _$FuelLogCopyWithImpl<$Res, $Val extends FuelLog>
    implements $FuelLogCopyWith<$Res> {
  _$FuelLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? vehicleId = freezed,
    Object? odometer = null,
    Object? fuelQuantity = null,
    Object? totalCost = null,
    Object? stationName = freezed,
    Object? date = freezed,
    Object? fuelPrice = freezed,
    Object? remainingRange = freezed,
    Object? isFullTank = null,
    Object? location = freezed,
    Object? notes = freezed,
    Object? paymentMethod = freezed,
    Object? billImagePath = freezed,
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
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as int?,
      odometer: null == odometer
          ? _value.odometer
          : odometer // ignore: cast_nullable_to_non_nullable
              as double,
      fuelQuantity: null == fuelQuantity
          ? _value.fuelQuantity
          : fuelQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      stationName: freezed == stationName
          ? _value.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fuelPrice: freezed == fuelPrice
          ? _value.fuelPrice
          : fuelPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      remainingRange: freezed == remainingRange
          ? _value.remainingRange
          : remainingRange // ignore: cast_nullable_to_non_nullable
              as double?,
      isFullTank: null == isFullTank
          ? _value.isFullTank
          : isFullTank // ignore: cast_nullable_to_non_nullable
              as bool,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      billImagePath: freezed == billImagePath
          ? _value.billImagePath
          : billImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FuelLogImplCopyWith<$Res> implements $FuelLogCopyWith<$Res> {
  factory _$$FuelLogImplCopyWith(
          _$FuelLogImpl value, $Res Function(_$FuelLogImpl) then) =
      __$$FuelLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'vehicle_id') int? vehicleId,
      double odometer,
      @JsonKey(name: 'fuel_quantity') double fuelQuantity,
      @JsonKey(name: 'total_cost') double totalCost,
      @JsonKey(name: 'station_name') String? stationName,
      DateTime? date,
      @JsonKey(name: 'fuel_price') double? fuelPrice,
      @JsonKey(name: 'remaining_range') double? remainingRange,
      @JsonKey(name: 'is_full_tank') bool isFullTank,
      String? location,
      String? notes,
      @JsonKey(name: 'payment_method') String? paymentMethod,
      @JsonKey(name: 'bill_image_path') String? billImagePath});
}

/// @nodoc
class __$$FuelLogImplCopyWithImpl<$Res>
    extends _$FuelLogCopyWithImpl<$Res, _$FuelLogImpl>
    implements _$$FuelLogImplCopyWith<$Res> {
  __$$FuelLogImplCopyWithImpl(
      _$FuelLogImpl _value, $Res Function(_$FuelLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of FuelLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? vehicleId = freezed,
    Object? odometer = null,
    Object? fuelQuantity = null,
    Object? totalCost = null,
    Object? stationName = freezed,
    Object? date = freezed,
    Object? fuelPrice = freezed,
    Object? remainingRange = freezed,
    Object? isFullTank = null,
    Object? location = freezed,
    Object? notes = freezed,
    Object? paymentMethod = freezed,
    Object? billImagePath = freezed,
  }) {
    return _then(_$FuelLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as int?,
      odometer: null == odometer
          ? _value.odometer
          : odometer // ignore: cast_nullable_to_non_nullable
              as double,
      fuelQuantity: null == fuelQuantity
          ? _value.fuelQuantity
          : fuelQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      stationName: freezed == stationName
          ? _value.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fuelPrice: freezed == fuelPrice
          ? _value.fuelPrice
          : fuelPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      remainingRange: freezed == remainingRange
          ? _value.remainingRange
          : remainingRange // ignore: cast_nullable_to_non_nullable
              as double?,
      isFullTank: null == isFullTank
          ? _value.isFullTank
          : isFullTank // ignore: cast_nullable_to_non_nullable
              as bool,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      billImagePath: freezed == billImagePath
          ? _value.billImagePath
          : billImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FuelLogImpl implements _FuelLog {
  const _$FuelLogImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'vehicle_id') this.vehicleId,
      required this.odometer,
      @JsonKey(name: 'fuel_quantity') required this.fuelQuantity,
      @JsonKey(name: 'total_cost') required this.totalCost,
      @JsonKey(name: 'station_name') this.stationName,
      this.date,
      @JsonKey(name: 'fuel_price') this.fuelPrice,
      @JsonKey(name: 'remaining_range') this.remainingRange,
      @JsonKey(name: 'is_full_tank') this.isFullTank = false,
      this.location,
      this.notes,
      @JsonKey(name: 'payment_method') this.paymentMethod,
      @JsonKey(name: 'bill_image_path') this.billImagePath});

  factory _$FuelLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$FuelLogImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'vehicle_id')
  final int? vehicleId;
  @override
  final double odometer;
  @override
  @JsonKey(name: 'fuel_quantity')
  final double fuelQuantity;
  @override
  @JsonKey(name: 'total_cost')
  final double totalCost;
  @override
  @JsonKey(name: 'station_name')
  final String? stationName;
  @override
  final DateTime? date;
  @override
  @JsonKey(name: 'fuel_price')
  final double? fuelPrice;
  @override
  @JsonKey(name: 'remaining_range')
  final double? remainingRange;
  @override
  @JsonKey(name: 'is_full_tank')
  final bool isFullTank;
  @override
  final String? location;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @override
  @JsonKey(name: 'bill_image_path')
  final String? billImagePath;

  @override
  String toString() {
    return 'FuelLog(id: $id, userId: $userId, vehicleId: $vehicleId, odometer: $odometer, fuelQuantity: $fuelQuantity, totalCost: $totalCost, stationName: $stationName, date: $date, fuelPrice: $fuelPrice, remainingRange: $remainingRange, isFullTank: $isFullTank, location: $location, notes: $notes, paymentMethod: $paymentMethod, billImagePath: $billImagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.odometer, odometer) ||
                other.odometer == odometer) &&
            (identical(other.fuelQuantity, fuelQuantity) ||
                other.fuelQuantity == fuelQuantity) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.fuelPrice, fuelPrice) ||
                other.fuelPrice == fuelPrice) &&
            (identical(other.remainingRange, remainingRange) ||
                other.remainingRange == remainingRange) &&
            (identical(other.isFullTank, isFullTank) ||
                other.isFullTank == isFullTank) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.billImagePath, billImagePath) ||
                other.billImagePath == billImagePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      vehicleId,
      odometer,
      fuelQuantity,
      totalCost,
      stationName,
      date,
      fuelPrice,
      remainingRange,
      isFullTank,
      location,
      notes,
      paymentMethod,
      billImagePath);

  /// Create a copy of FuelLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelLogImplCopyWith<_$FuelLogImpl> get copyWith =>
      __$$FuelLogImplCopyWithImpl<_$FuelLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelLogImplToJson(
      this,
    );
  }
}

abstract class _FuelLog implements FuelLog {
  const factory _FuelLog(
          {required final int id,
          @JsonKey(name: 'user_id') required final int userId,
          @JsonKey(name: 'vehicle_id') final int? vehicleId,
          required final double odometer,
          @JsonKey(name: 'fuel_quantity') required final double fuelQuantity,
          @JsonKey(name: 'total_cost') required final double totalCost,
          @JsonKey(name: 'station_name') final String? stationName,
          final DateTime? date,
          @JsonKey(name: 'fuel_price') final double? fuelPrice,
          @JsonKey(name: 'remaining_range') final double? remainingRange,
          @JsonKey(name: 'is_full_tank') final bool isFullTank,
          final String? location,
          final String? notes,
          @JsonKey(name: 'payment_method') final String? paymentMethod,
          @JsonKey(name: 'bill_image_path') final String? billImagePath}) =
      _$FuelLogImpl;

  factory _FuelLog.fromJson(Map<String, dynamic> json) = _$FuelLogImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @JsonKey(name: 'vehicle_id')
  int? get vehicleId;
  @override
  double get odometer;
  @override
  @JsonKey(name: 'fuel_quantity')
  double get fuelQuantity;
  @override
  @JsonKey(name: 'total_cost')
  double get totalCost;
  @override
  @JsonKey(name: 'station_name')
  String? get stationName;
  @override
  DateTime? get date;
  @override
  @JsonKey(name: 'fuel_price')
  double? get fuelPrice;
  @override
  @JsonKey(name: 'remaining_range')
  double? get remainingRange;
  @override
  @JsonKey(name: 'is_full_tank')
  bool get isFullTank;
  @override
  String? get location;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'payment_method')
  String? get paymentMethod;
  @override
  @JsonKey(name: 'bill_image_path')
  String? get billImagePath;

  /// Create a copy of FuelLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelLogImplCopyWith<_$FuelLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
