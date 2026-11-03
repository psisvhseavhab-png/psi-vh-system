class InventoryProductModel {
  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final String? nameKhmer;
  final String category; // BUS_PASS, UNIFORM, TEXTBOOK, STATIONERY
  final String sizeVariant;
  int stockQuantity;
  final int minSafetyLevel;
  final double unitCostUsd;
  final double sellingPriceUsd;
  final double sellingPriceKhr;
  final bool isLowStock;

  InventoryProductModel({
    required this.id,
    required this.sku,
    this.barcode,
    required this.name,
    this.nameKhmer,
    required this.category,
    required this.sizeVariant,
    required this.stockQuantity,
    required this.minSafetyLevel,
    required this.unitCostUsd,
    required this.sellingPriceUsd,
    required this.sellingPriceKhr,
    required this.isLowStock,
  });

  factory InventoryProductModel.fromJson(Map<String, dynamic> json) {
    return InventoryProductModel(
      id: json['id'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      name: json['name'] ?? '',
      nameKhmer: json['name_khmer'],
      category: json['category'] ?? 'STATIONERY',
      sizeVariant: json['size_variant'] ?? 'Standard',
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      minSafetyLevel: (json['min_safety_level'] as num?)?.toInt() ?? 10,
      unitCostUsd: (json['unit_cost_usd'] as num?)?.toDouble() ?? 0.0,
      sellingPriceUsd: (json['selling_price_usd'] as num?)?.toDouble() ?? 0.0,
      sellingPriceKhr: (json['selling_price_khr'] as num?)?.toDouble() ?? 0.0,
      isLowStock: json['is_low_stock'] ?? false,
    );
  }
}

