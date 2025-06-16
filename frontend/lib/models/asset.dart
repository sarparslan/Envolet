/// A bank card or account the user keeps track of.
class Asset {
  const Asset({
    required this.id,
    required this.bankName,
    required this.amount,
    required this.lastFourDigits,
    required this.brand,
    required this.color,
  });

  final String id;
  final String bankName;
  final int amount;
  final String lastFourDigits;
  final String brand;

  /// Card color as a hex string, e.g. `#1E88E5`.
  final String color;

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        id: json['_id'] as String,
        bankName: json['bankName'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toInt(),
        lastFourDigits: json['lastFourDigits'] as String? ?? '',
        brand: json['brand'] as String? ?? '',
        color: json['color'] as String? ?? '',
      );
}

/// Values entered in the asset form, before the asset is persisted.
class AssetDraft {
  const AssetDraft({
    required this.bankName,
    required this.amount,
    required this.lastFourDigits,
    required this.brand,
    required this.color,
  });

  final String bankName;
  final int amount;
  final String lastFourDigits;
  final String brand;
  final String color;

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'amount': amount,
        'lastFourDigits': lastFourDigits,
        'brand': brand,
        'color': color,
      };
}
