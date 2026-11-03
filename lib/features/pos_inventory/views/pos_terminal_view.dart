import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/printing_service.dart';
import '../../../models/inventory_model.dart';
import '../../../widgets/custom_badge.dart';

class PosTerminalView extends StatefulWidget {
  const PosTerminalView({Key? key}) : super(key: key);

  @override
  State<PosTerminalView> createState() => _PosTerminalViewState();
}

class _PosTerminalViewState extends State<PosTerminalView> {
  bool _isLoading = true;
  List<InventoryProductModel> _products = [];
  List<dynamic> _busRoutes = [];
  String _selectedCategory = 'ALL';

  // Cart state: Map<productId, quantity>
  final Map<String, int> _cart = {};
  String _paymentMethod = 'KHQR_BAKONG';

  @override
  void initState() {
    super.initState();
    _loadProductsAndRoutes();
  }

  Future<void> _loadProductsAndRoutes() async {
    setState(() => _isLoading = true);
    try {
      final resProd = await ApiClient().get(ApiEndpoints.inventoryProducts);
      final resBus = await ApiClient().get(ApiEndpoints.busRoutes);

      if (mounted) {
        setState(() {
          _products = (resProd.data as List)
              .map((p) => InventoryProductModel.fromJson(p))
              .toList();
          _busRoutes = resBus.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addToCart(InventoryProductModel product) {
    if (product.category != 'BUS_PASS' && product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot add ${product.name}: Out of Stock!')),
      );
      return;
    }

    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        if (_cart[productId]! > 1) {
          _cart[productId] = _cart[productId]! - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  double get _cartSubtotalUsd {
    double sum = 0.0;
    for (final entry in _cart.entries) {
      final prod = _products.firstWhere((p) => p.id == entry.key);
      sum += prod.sellingPriceUsd * entry.value;
    }
    return sum;
  }

  Future<void> _processCheckout(bool isThermalReceipt) async {
    if (_cart.isEmpty) return;

    try {
      final itemsPayload = _cart.entries.map((e) => {
        'product_id': e.key,
        'quantity': e.value,
      }).toList();

      final res = await ApiClient().post(
        ApiEndpoints.posCheckout,
        data: {
          'items': itemsPayload,
          'payment_method': _paymentMethod,
          'receipt_type': isThermalReceipt ? 'THERMAL_80MM' : 'A4_INVOICE',
          'discount_usd': 0.0,
        },
      );

      final invData = res.data;
      final receiptData = invData['receipt_data'];

      // Print immediately
      if (isThermalReceipt) {
        await PrintingService.printThermalReceipt(
          invoiceNumber: receiptData['invoice_number'],
          cashierName: 'PSI-VH Cashier',
          timestamp: DateTime.now(),
          items: (receiptData['items'] as List).map((i) => {
            'name': i['name'],
            'qty': i['qty'],
            'total': (i['total_usd'] as num).toDouble(),
          }).toList(),
          totalUsd: (receiptData['total_usd'] as num).toDouble(),
          totalKhr: (receiptData['total_khr'] as num).toDouble(),
          paymentMethod: _paymentMethod,
        );
      } else {
        await PrintingService.printA4Invoice(
          invoiceNumber: receiptData['invoice_number'],
          studentName: 'Customer / Student',
          studentCode: 'PSI-POS',
          programName: 'School Uniforms & Materials Store',
          lineItems: (receiptData['items'] as List).map((i) => {
            'name': i['name'],
            'unit_price': (i['price_usd'] as num).toDouble(),
            'qty': i['qty'],
            'total': (i['total_usd'] as num).toDouble(),
          }).toList(),
          totalUsd: (receiptData['total_usd'] as num).toDouble(),
          totalKhr: (receiptData['total_khr'] as num).toDouble(),
        );
      }

      setState(() {
        _cart.clear();
      });
      _loadProductsAndRoutes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${receiptData['invoice_number']} completed & stock deducted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredProducts = _selectedCategory == 'ALL'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Row(
      children: [
        // LEFT: Product Catalog & Category Filter
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Category Filter Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'School Store POS & Stock Inventory',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    CustomBadge.success('Automatic Stock Deduction Enabled'),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryFilterChip('ALL', 'All Items'),
                      _categoryFilterChip('UNIFORM', 'Uniforms (XS-XL)'),
                      _categoryFilterChip('BUS_PASS', 'Bus Passes (Route 1 & 2)'),
                      _categoryFilterChip('TEXTBOOK', 'Cambridge Textbooks'),
                      _categoryFilterChip('STATIONERY', 'Stationery Kits'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Products Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final p = filteredProducts[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: p.isLowStock ? AppColors.dangerRed.withOpacity(0.4) : AppColors.cardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomBadge(
                                  label: p.sizeVariant,
                                  backgroundColor: AppColors.lightBlue,
                                  textColor: AppColors.primaryBlue,
                                ),
                                if (p.category != 'BUS_PASS')
                                  Text(
                                    'Stock: ${p.stockQuantity}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: p.isLowStock ? AppColors.dangerRed : AppColors.successGreen,
                                    ),
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.nameKhmer != null)
                                  Text(
                                    p.nameKhmer!,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                    maxLines: 1,
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatUsd(p.sellingPriceUsd),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatKhr(p.sellingPriceKhr),
                                      style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => _addToCart(p),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  child: const Text('+ Add', style: TextStyle(fontSize: 10, color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // RIGHT: Live POS Cart & Terminal Checkout
        Container(
          width: 360,
          color: AppColors.surfaceWhite,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Checkout Cart', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: AppColors.dangerRed, size: 20),
                    onPressed: () => setState(() => _cart.clear()),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _cart.isEmpty
                    ? const Center(
                        child: Text('Cart is empty. Tap items on the left to add.', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      )
                    : ListView(
                        children: _cart.entries.map((entry) {
                          final prod = _products.firstWhere((p) => p.id == entry.key);
                          final lineTotal = prod.sellingPriceUsd * entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      Text('\$${prod.sellingPriceUsd} each', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 16),
                                      onPressed: () => _removeFromCart(prod.id),
                                    ),
                                    Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 16),
                                      onPressed: () => _addToCart(prod),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  CurrencyFormatter.formatUsd(lineTotal),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const Divider(),

              // Payment Method Selector
              const Text('Payment Gateway:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                isExpanded: true,
                value: _paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'KHQR_BAKONG', child: Text('National KHQR (Bakong Riel / USD)')),
                  DropdownMenuItem(value: 'CASH_USD', child: Text('Cash (US Dollars)')),
                  DropdownMenuItem(value: 'CASH_KHR', child: Text('Cash (Khmer Riel)')),
                  DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Direct Bank Transfer (ABA/Canadia)')),
                ],
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              const SizedBox(height: 12),

              // Totals in USD & KHR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total (USD):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(CurrencyFormatter.formatUsd(_cartSubtotalUsd), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total (Khmer Riel):', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text(CurrencyFormatter.formatKhr(_cartSubtotalUsd * 4100.0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentGold)),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _cart.isEmpty ? null : () => _processCheckout(true),
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Checkout & Print Thermal 80mm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  minimumSize: const Size.fromHeight(42),
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: _cart.isEmpty ? null : () => _processCheckout(false),
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('Generate A4 School Invoice', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(38),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryFilterChip(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selectedColor: AppColors.primaryNavy,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
        onSelected: (_) => setState(() => _selectedCategory = cat),
      ),
    );
  }
}

