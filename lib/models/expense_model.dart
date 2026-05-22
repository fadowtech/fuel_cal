import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'vehicle_id') int? vehicleId,
    required String category,
    required String title,
    required double amount,
    DateTime? date,
    String? notes,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
