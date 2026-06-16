// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FuelLog {

 int get id;@JsonKey(name: 'user_id') int get userId;@JsonKey(name: 'vehicle_id') int? get vehicleId; double get odometer;@JsonKey(name: 'fuel_quantity') double get fuelQuantity;@JsonKey(name: 'total_cost') double get totalCost;@JsonKey(name: 'station_name') String? get stationName; DateTime? get date;@JsonKey(name: 'fuel_price') double? get fuelPrice;@JsonKey(name: 'remaining_range') double? get remainingRange;@JsonKey(name: 'remaining_range_after') double? get remainingRangeAfter;@JsonKey(name: 'is_full_tank') bool get isFullTank;@JsonKey(name: 'missed_fillup') bool get missedFillup; String? get location; String? get notes;@JsonKey(name: 'payment_method') String? get paymentMethod;@JsonKey(name: 'bill_image_path') String? get billImagePath;
/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FuelLogCopyWith<FuelLog> get copyWith => _$FuelLogCopyWithImpl<FuelLog>(this as FuelLog, _$identity);

  /// Serializes this FuelLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FuelLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.odometer, odometer) || other.odometer == odometer)&&(identical(other.fuelQuantity, fuelQuantity) || other.fuelQuantity == fuelQuantity)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.date, date) || other.date == date)&&(identical(other.fuelPrice, fuelPrice) || other.fuelPrice == fuelPrice)&&(identical(other.remainingRange, remainingRange) || other.remainingRange == remainingRange)&&(identical(other.remainingRangeAfter, remainingRangeAfter) || other.remainingRangeAfter == remainingRangeAfter)&&(identical(other.isFullTank, isFullTank) || other.isFullTank == isFullTank)&&(identical(other.missedFillup, missedFillup) || other.missedFillup == missedFillup)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.billImagePath, billImagePath) || other.billImagePath == billImagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,vehicleId,odometer,fuelQuantity,totalCost,stationName,date,fuelPrice,remainingRange,remainingRangeAfter,isFullTank,missedFillup,location,notes,paymentMethod,billImagePath);

@override
String toString() {
  return 'FuelLog(id: $id, userId: $userId, vehicleId: $vehicleId, odometer: $odometer, fuelQuantity: $fuelQuantity, totalCost: $totalCost, stationName: $stationName, date: $date, fuelPrice: $fuelPrice, remainingRange: $remainingRange, remainingRangeAfter: $remainingRangeAfter, isFullTank: $isFullTank, missedFillup: $missedFillup, location: $location, notes: $notes, paymentMethod: $paymentMethod, billImagePath: $billImagePath)';
}


}

/// @nodoc
abstract mixin class $FuelLogCopyWith<$Res>  {
  factory $FuelLogCopyWith(FuelLog value, $Res Function(FuelLog) _then) = _$FuelLogCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int userId,@JsonKey(name: 'vehicle_id') int? vehicleId, double odometer,@JsonKey(name: 'fuel_quantity') double fuelQuantity,@JsonKey(name: 'total_cost') double totalCost,@JsonKey(name: 'station_name') String? stationName, DateTime? date,@JsonKey(name: 'fuel_price') double? fuelPrice,@JsonKey(name: 'remaining_range') double? remainingRange,@JsonKey(name: 'remaining_range_after') double? remainingRangeAfter,@JsonKey(name: 'is_full_tank') bool isFullTank,@JsonKey(name: 'missed_fillup') bool missedFillup, String? location, String? notes,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'bill_image_path') String? billImagePath
});




}
/// @nodoc
class _$FuelLogCopyWithImpl<$Res>
    implements $FuelLogCopyWith<$Res> {
  _$FuelLogCopyWithImpl(this._self, this._then);

  final FuelLog _self;
  final $Res Function(FuelLog) _then;

/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? vehicleId = freezed,Object? odometer = null,Object? fuelQuantity = null,Object? totalCost = null,Object? stationName = freezed,Object? date = freezed,Object? fuelPrice = freezed,Object? remainingRange = freezed,Object? remainingRangeAfter = freezed,Object? isFullTank = null,Object? missedFillup = null,Object? location = freezed,Object? notes = freezed,Object? paymentMethod = freezed,Object? billImagePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,odometer: null == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as double,fuelQuantity: null == fuelQuantity ? _self.fuelQuantity : fuelQuantity // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,fuelPrice: freezed == fuelPrice ? _self.fuelPrice : fuelPrice // ignore: cast_nullable_to_non_nullable
as double?,remainingRange: freezed == remainingRange ? _self.remainingRange : remainingRange // ignore: cast_nullable_to_non_nullable
as double?,remainingRangeAfter: freezed == remainingRangeAfter ? _self.remainingRangeAfter : remainingRangeAfter // ignore: cast_nullable_to_non_nullable
as double?,isFullTank: null == isFullTank ? _self.isFullTank : isFullTank // ignore: cast_nullable_to_non_nullable
as bool,missedFillup: null == missedFillup ? _self.missedFillup : missedFillup // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,billImagePath: freezed == billImagePath ? _self.billImagePath : billImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FuelLog].
extension FuelLogPatterns on FuelLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FuelLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FuelLog value)  $default,){
final _that = this;
switch (_that) {
case _FuelLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FuelLog value)?  $default,){
final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int userId, @JsonKey(name: 'vehicle_id')  int? vehicleId,  double odometer, @JsonKey(name: 'fuel_quantity')  double fuelQuantity, @JsonKey(name: 'total_cost')  double totalCost, @JsonKey(name: 'station_name')  String? stationName,  DateTime? date, @JsonKey(name: 'fuel_price')  double? fuelPrice, @JsonKey(name: 'remaining_range')  double? remainingRange, @JsonKey(name: 'remaining_range_after')  double? remainingRangeAfter, @JsonKey(name: 'is_full_tank')  bool isFullTank, @JsonKey(name: 'missed_fillup')  bool missedFillup,  String? location,  String? notes, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'bill_image_path')  String? billImagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that.id,_that.userId,_that.vehicleId,_that.odometer,_that.fuelQuantity,_that.totalCost,_that.stationName,_that.date,_that.fuelPrice,_that.remainingRange,_that.remainingRangeAfter,_that.isFullTank,_that.missedFillup,_that.location,_that.notes,_that.paymentMethod,_that.billImagePath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int userId, @JsonKey(name: 'vehicle_id')  int? vehicleId,  double odometer, @JsonKey(name: 'fuel_quantity')  double fuelQuantity, @JsonKey(name: 'total_cost')  double totalCost, @JsonKey(name: 'station_name')  String? stationName,  DateTime? date, @JsonKey(name: 'fuel_price')  double? fuelPrice, @JsonKey(name: 'remaining_range')  double? remainingRange, @JsonKey(name: 'remaining_range_after')  double? remainingRangeAfter, @JsonKey(name: 'is_full_tank')  bool isFullTank, @JsonKey(name: 'missed_fillup')  bool missedFillup,  String? location,  String? notes, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'bill_image_path')  String? billImagePath)  $default,) {final _that = this;
switch (_that) {
case _FuelLog():
return $default(_that.id,_that.userId,_that.vehicleId,_that.odometer,_that.fuelQuantity,_that.totalCost,_that.stationName,_that.date,_that.fuelPrice,_that.remainingRange,_that.remainingRangeAfter,_that.isFullTank,_that.missedFillup,_that.location,_that.notes,_that.paymentMethod,_that.billImagePath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'user_id')  int userId, @JsonKey(name: 'vehicle_id')  int? vehicleId,  double odometer, @JsonKey(name: 'fuel_quantity')  double fuelQuantity, @JsonKey(name: 'total_cost')  double totalCost, @JsonKey(name: 'station_name')  String? stationName,  DateTime? date, @JsonKey(name: 'fuel_price')  double? fuelPrice, @JsonKey(name: 'remaining_range')  double? remainingRange, @JsonKey(name: 'remaining_range_after')  double? remainingRangeAfter, @JsonKey(name: 'is_full_tank')  bool isFullTank, @JsonKey(name: 'missed_fillup')  bool missedFillup,  String? location,  String? notes, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'bill_image_path')  String? billImagePath)?  $default,) {final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that.id,_that.userId,_that.vehicleId,_that.odometer,_that.fuelQuantity,_that.totalCost,_that.stationName,_that.date,_that.fuelPrice,_that.remainingRange,_that.remainingRangeAfter,_that.isFullTank,_that.missedFillup,_that.location,_that.notes,_that.paymentMethod,_that.billImagePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FuelLog implements FuelLog {
  const _FuelLog({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'vehicle_id') this.vehicleId, required this.odometer, @JsonKey(name: 'fuel_quantity') required this.fuelQuantity, @JsonKey(name: 'total_cost') required this.totalCost, @JsonKey(name: 'station_name') this.stationName, this.date, @JsonKey(name: 'fuel_price') this.fuelPrice, @JsonKey(name: 'remaining_range') this.remainingRange, @JsonKey(name: 'remaining_range_after') this.remainingRangeAfter, @JsonKey(name: 'is_full_tank') this.isFullTank = false, @JsonKey(name: 'missed_fillup') this.missedFillup = false, this.location, this.notes, @JsonKey(name: 'payment_method') this.paymentMethod, @JsonKey(name: 'bill_image_path') this.billImagePath});
  factory _FuelLog.fromJson(Map<String, dynamic> json) => _$FuelLogFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  int userId;
@override@JsonKey(name: 'vehicle_id') final  int? vehicleId;
@override final  double odometer;
@override@JsonKey(name: 'fuel_quantity') final  double fuelQuantity;
@override@JsonKey(name: 'total_cost') final  double totalCost;
@override@JsonKey(name: 'station_name') final  String? stationName;
@override final  DateTime? date;
@override@JsonKey(name: 'fuel_price') final  double? fuelPrice;
@override@JsonKey(name: 'remaining_range') final  double? remainingRange;
@override@JsonKey(name: 'remaining_range_after') final  double? remainingRangeAfter;
@override@JsonKey(name: 'is_full_tank') final  bool isFullTank;
@override@JsonKey(name: 'missed_fillup') final  bool missedFillup;
@override final  String? location;
@override final  String? notes;
@override@JsonKey(name: 'payment_method') final  String? paymentMethod;
@override@JsonKey(name: 'bill_image_path') final  String? billImagePath;

/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FuelLogCopyWith<_FuelLog> get copyWith => __$FuelLogCopyWithImpl<_FuelLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FuelLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FuelLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.odometer, odometer) || other.odometer == odometer)&&(identical(other.fuelQuantity, fuelQuantity) || other.fuelQuantity == fuelQuantity)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.date, date) || other.date == date)&&(identical(other.fuelPrice, fuelPrice) || other.fuelPrice == fuelPrice)&&(identical(other.remainingRange, remainingRange) || other.remainingRange == remainingRange)&&(identical(other.remainingRangeAfter, remainingRangeAfter) || other.remainingRangeAfter == remainingRangeAfter)&&(identical(other.isFullTank, isFullTank) || other.isFullTank == isFullTank)&&(identical(other.missedFillup, missedFillup) || other.missedFillup == missedFillup)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.billImagePath, billImagePath) || other.billImagePath == billImagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,vehicleId,odometer,fuelQuantity,totalCost,stationName,date,fuelPrice,remainingRange,remainingRangeAfter,isFullTank,missedFillup,location,notes,paymentMethod,billImagePath);

@override
String toString() {
  return 'FuelLog(id: $id, userId: $userId, vehicleId: $vehicleId, odometer: $odometer, fuelQuantity: $fuelQuantity, totalCost: $totalCost, stationName: $stationName, date: $date, fuelPrice: $fuelPrice, remainingRange: $remainingRange, remainingRangeAfter: $remainingRangeAfter, isFullTank: $isFullTank, missedFillup: $missedFillup, location: $location, notes: $notes, paymentMethod: $paymentMethod, billImagePath: $billImagePath)';
}


}

/// @nodoc
abstract mixin class _$FuelLogCopyWith<$Res> implements $FuelLogCopyWith<$Res> {
  factory _$FuelLogCopyWith(_FuelLog value, $Res Function(_FuelLog) _then) = __$FuelLogCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int userId,@JsonKey(name: 'vehicle_id') int? vehicleId, double odometer,@JsonKey(name: 'fuel_quantity') double fuelQuantity,@JsonKey(name: 'total_cost') double totalCost,@JsonKey(name: 'station_name') String? stationName, DateTime? date,@JsonKey(name: 'fuel_price') double? fuelPrice,@JsonKey(name: 'remaining_range') double? remainingRange,@JsonKey(name: 'remaining_range_after') double? remainingRangeAfter,@JsonKey(name: 'is_full_tank') bool isFullTank,@JsonKey(name: 'missed_fillup') bool missedFillup, String? location, String? notes,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'bill_image_path') String? billImagePath
});




}
/// @nodoc
class __$FuelLogCopyWithImpl<$Res>
    implements _$FuelLogCopyWith<$Res> {
  __$FuelLogCopyWithImpl(this._self, this._then);

  final _FuelLog _self;
  final $Res Function(_FuelLog) _then;

/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? vehicleId = freezed,Object? odometer = null,Object? fuelQuantity = null,Object? totalCost = null,Object? stationName = freezed,Object? date = freezed,Object? fuelPrice = freezed,Object? remainingRange = freezed,Object? remainingRangeAfter = freezed,Object? isFullTank = null,Object? missedFillup = null,Object? location = freezed,Object? notes = freezed,Object? paymentMethod = freezed,Object? billImagePath = freezed,}) {
  return _then(_FuelLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,odometer: null == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as double,fuelQuantity: null == fuelQuantity ? _self.fuelQuantity : fuelQuantity // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,fuelPrice: freezed == fuelPrice ? _self.fuelPrice : fuelPrice // ignore: cast_nullable_to_non_nullable
as double?,remainingRange: freezed == remainingRange ? _self.remainingRange : remainingRange // ignore: cast_nullable_to_non_nullable
as double?,remainingRangeAfter: freezed == remainingRangeAfter ? _self.remainingRangeAfter : remainingRangeAfter // ignore: cast_nullable_to_non_nullable
as double?,isFullTank: null == isFullTank ? _self.isFullTank : isFullTank // ignore: cast_nullable_to_non_nullable
as bool,missedFillup: null == missedFillup ? _self.missedFillup : missedFillup // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,billImagePath: freezed == billImagePath ? _self.billImagePath : billImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
