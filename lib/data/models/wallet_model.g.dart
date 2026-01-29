// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  balance: (json['balance'] as num).toInt(),
  transactionCount: (json['transaction_count'] as num?)?.toInt(),
  formattedBalance: json['formatted_balance'] as String?,
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'transaction_count': instance.transactionCount,
      'formatted_balance': instance.formattedBalance,
    };

WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionModel(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  typeKorean: json['type_korean'] as String?,
  amount: (json['amount'] as num).toInt(),
  formattedAmount: json['formatted_amount'] as String?,
  description: json['description'] as String?,
  paymentMethod: json['payment_method'] as String?,
  status: json['status'] as String,
  createdAt: json['created_at'] as String?,
  formattedDate: json['formatted_date'] as String?,
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'type_korean': instance.typeKorean,
  'amount': instance.amount,
  'formatted_amount': instance.formattedAmount,
  'description': instance.description,
  'payment_method': instance.paymentMethod,
  'status': instance.status,
  'created_at': instance.createdAt,
  'formatted_date': instance.formattedDate,
};
