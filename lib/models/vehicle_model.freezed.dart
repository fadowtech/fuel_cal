// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vehicle {

 int get id;@JsonKey(name: 'user_id') int get userId; String get make; String get model; int get year;@JsonKey(name: 'fuel_type') String get fuelType;@JsonKey(name: 'tank_capacity') double get tankCapacity;@JsonKey(name: 'vehicle_number') String? get vehicleNumber; String? get variant;@JsonKey(name: 'vehicle_type') String? get vehicleType;@JsonKey(name: 'tank_type') String? get tankType;@JsonKey(name: 'highest_avg_mileage') double? get highestAvgMileage;@JsonKey(name: 'avg_mileage') double? get avgMileage;@JsonKey(name: 'poor_mileage') double? get poorMileage; String? get notes; String? get color;@JsonKey(name: 'is_default') bool get isDefault;
/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCopyWith<Vehicle> get copyWith => _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.tankCapacity, tankCapacity) || other.tankCapacity == tankCapacity)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.tankType, tankType) || other.tankType == tankType)&&(identical(other.highestAvgMileage, highestAvgMileage) || other.highestAvgMileage == highestAvgMileage)&&(identical(other.avgMileage, avgMileage) || other.avgMileage == avgMileage)&&(identical(other.poorMileage, poorMileage) || other.poorMileage == poorMileage)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.color, color) || other.color == color)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,make,model,year,fuelType,tankCapacity,vehicleNumber,variant,vehicleType,tankType,highestAvgMileage,avgMileage,poorMileage,notes,color,isDefault);

@override
String toString() {
  return 'Vehicle(id: $id, userId: $userId, make: $make, model: $model, year: $year, fuelType: $fuelType, tankCapacity: $tankCapacity, vehicleNumber: $vehicleNumber, variant: $variant, vehicleType: $vehicleType, tankType: $tankType, highestAvgMileage: $highestAvgMileage, avgMileage: $avgMileage, poorMileage: $poorMileage, notes: $notes, color: $color, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res>  {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) = _$VehicleCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int userId, String make, String model, int year,@JsonKey(name: 'fuel_type') String fuelType,@JsonKey(name: 'tank_capacity') double tankCapacity,@JsonKey(name: 'vehicle_number') String? vehicleNumber, String? variant,@JsonKey(name: 'vehicle_type') String? vehicleType,@JsonKey(name: 'tank_type') String? tankType,@JsonKey(name: 'highest_avg_mileage') double? highestAvgMileage,@JsonKey(name: 'avg_mileage') double? avgMileage,@JsonKey(name: 'poor_mileage') double? poorMileage, String? notes, String? color,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class _$VehicleCopyWithImpl<$Res>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? make = null,Object? model = null,Object? year = null,Object? fuelType = null,Object? tankCapacity = null,Object? vehicleNumber = freezed,Object? variant = freezed,Object? vehicleType = freezed,Object? tankType = freezed,Object? highestAvgMileage = freezed,Object? avgMileage = freezed,Object? poorMileage = freezed,Object? notes = freezed,Object? color = freezed,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String,tankCapacity: null == tankCapacity ? _self.tankCapacity : tankCapacity // ignore: cast_nullable_to_non_nullable
as double,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,tankType: freezed == tankType ? _self.tankType : tankType // ignore: cast_nullable_to_non_nullable
as String?,highestAvgMileage: freezed == highestAvgMileage ? _self.highestAvgMileage : highestAvgMileage // ignore: cast_nullable_to_non_nullable
as double?,avgMileage: freezed == avgMileage ? _self.avgMileage : avgMileage // ignore: cast_nullable_to_non_nullable
as double?,poorMileage: freezed == poorMileage ? _self.poorMileage : poorMileage // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vehicle value)  $default,){
final _that = this;
switch (_that) {
case _Vehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vehicle value)?  $default,){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int userId,  String make,  String model,  int year, @JsonKey(name: 'fuel_type')  String fuelType, @JsonKey(name: 'tank_capacity')  double tankCapacity, @JsonKey(name: 'vehicle_number')  String? vehicleNumber,  String? variant, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'tank_type')  String? tankType, @JsonKey(name: 'highest_avg_mileage')  double? highestAvgMileage, @JsonKey(name: 'avg_mileage')  double? avgMileage, @JsonKey(name: 'poor_mileage')  double? poorMileage,  String? notes,  String? color, @JsonKey(name: 'is_default')  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.userId,_that.make,_that.model,_that.year,_that.fuelType,_that.tankCapacity,_that.vehicleNumber,_that.variant,_that.vehicleType,_that.tankType,_that.highestAvgMileage,_that.avgMileage,_that.poorMileage,_that.notes,_that.color,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int userId,  String make,  String model,  int year, @JsonKey(name: 'fuel_type')  String fuelType, @JsonKey(name: 'tank_capacity')  double tankCapacity, @JsonKey(name: 'vehicle_number')  String? vehicleNumber,  String? variant, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'tank_type')  String? tankType, @JsonKey(name: 'highest_avg_mileage')  double? highestAvgMileage, @JsonKey(name: 'avg_mileage')  double? avgMileage, @JsonKey(name: 'poor_mileage')  double? poorMileage,  String? notes,  String? color, @JsonKey(name: 'is_default')  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that.id,_that.userId,_that.make,_that.model,_that.year,_that.fuelType,_that.tankCapacity,_that.vehicleNumber,_that.variant,_that.vehicleType,_that.tankType,_that.highestAvgMileage,_that.avgMileage,_that.poorMileage,_that.notes,_that.color,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'user_id')  int userId,  String make,  String model,  int year, @JsonKey(name: 'fuel_type')  String fuelType, @JsonKey(name: 'tank_capacity')  double tankCapacity, @JsonKey(name: 'vehicle_number')  String? vehicleNumber,  String? variant, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'tank_type')  String? tankType, @JsonKey(name: 'highest_avg_mileage')  double? highestAvgMileage, @JsonKey(name: 'avg_mileage')  double? avgMileage, @JsonKey(name: 'poor_mileage')  double? poorMileage,  String? notes,  String? color, @JsonKey(name: 'is_default')  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.userId,_that.make,_that.model,_that.year,_that.fuelType,_that.tankCapacity,_that.vehicleNumber,_that.variant,_that.vehicleType,_that.tankType,_that.highestAvgMileage,_that.avgMileage,_that.poorMileage,_that.notes,_that.color,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vehicle implements Vehicle {
  const _Vehicle({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.make, required this.model, required this.year, @JsonKey(name: 'fuel_type') required this.fuelType, @JsonKey(name: 'tank_capacity') required this.tankCapacity, @JsonKey(name: 'vehicle_number') this.vehicleNumber, this.variant, @JsonKey(name: 'vehicle_type') this.vehicleType, @JsonKey(name: 'tank_type') this.tankType, @JsonKey(name: 'highest_avg_mileage') this.highestAvgMileage, @JsonKey(name: 'avg_mileage') this.avgMileage, @JsonKey(name: 'poor_mileage') this.poorMileage, this.notes, this.color, @JsonKey(name: 'is_default') this.isDefault = false});
  factory _Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  int userId;
@override final  String make;
@override final  String model;
@override final  int year;
@override@JsonKey(name: 'fuel_type') final  String fuelType;
@override@JsonKey(name: 'tank_capacity') final  double tankCapacity;
@override@JsonKey(name: 'vehicle_number') final  String? vehicleNumber;
@override final  String? variant;
@override@JsonKey(name: 'vehicle_type') final  String? vehicleType;
@override@JsonKey(name: 'tank_type') final  String? tankType;
@override@JsonKey(name: 'highest_avg_mileage') final  double? highestAvgMileage;
@override@JsonKey(name: 'avg_mileage') final  double? avgMileage;
@override@JsonKey(name: 'poor_mileage') final  double? poorMileage;
@override final  String? notes;
@override final  String? color;
@override@JsonKey(name: 'is_default') final  bool isDefault;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCopyWith<_Vehicle> get copyWith => __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.tankCapacity, tankCapacity) || other.tankCapacity == tankCapacity)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.tankType, tankType) || other.tankType == tankType)&&(identical(other.highestAvgMileage, highestAvgMileage) || other.highestAvgMileage == highestAvgMileage)&&(identical(other.avgMileage, avgMileage) || other.avgMileage == avgMileage)&&(identical(other.poorMileage, poorMileage) || other.poorMileage == poorMileage)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.color, color) || other.color == color)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,make,model,year,fuelType,tankCapacity,vehicleNumber,variant,vehicleType,tankType,highestAvgMileage,avgMileage,poorMileage,notes,color,isDefault);

@override
String toString() {
  return 'Vehicle(id: $id, userId: $userId, make: $make, model: $model, year: $year, fuelType: $fuelType, tankCapacity: $tankCapacity, vehicleNumber: $vehicleNumber, variant: $variant, vehicleType: $vehicleType, tankType: $tankType, highestAvgMileage: $highestAvgMileage, avgMileage: $avgMileage, poorMileage: $poorMileage, notes: $notes, color: $color, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) = __$VehicleCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int userId, String make, String model, int year,@JsonKey(name: 'fuel_type') String fuelType,@JsonKey(name: 'tank_capacity') double tankCapacity,@JsonKey(name: 'vehicle_number') String? vehicleNumber, String? variant,@JsonKey(name: 'vehicle_type') String? vehicleType,@JsonKey(name: 'tank_type') String? tankType,@JsonKey(name: 'highest_avg_mileage') double? highestAvgMileage,@JsonKey(name: 'avg_mileage') double? avgMileage,@JsonKey(name: 'poor_mileage') double? poorMileage, String? notes, String? color,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class __$VehicleCopyWithImpl<$Res>
    implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? make = null,Object? model = null,Object? year = null,Object? fuelType = null,Object? tankCapacity = null,Object? vehicleNumber = freezed,Object? variant = freezed,Object? vehicleType = freezed,Object? tankType = freezed,Object? highestAvgMileage = freezed,Object? avgMileage = freezed,Object? poorMileage = freezed,Object? notes = freezed,Object? color = freezed,Object? isDefault = null,}) {
  return _then(_Vehicle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String,tankCapacity: null == tankCapacity ? _self.tankCapacity : tankCapacity // ignore: cast_nullable_to_non_nullable
as double,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,tankType: freezed == tankType ? _self.tankType : tankType // ignore: cast_nullable_to_non_nullable
as String?,highestAvgMileage: freezed == highestAvgMileage ? _self.highestAvgMileage : highestAvgMileage // ignore: cast_nullable_to_non_nullable
as double?,avgMileage: freezed == avgMileage ? _self.avgMileage : avgMileage // ignore: cast_nullable_to_non_nullable
as double?,poorMileage: freezed == poorMileage ? _self.poorMileage : poorMileage // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
