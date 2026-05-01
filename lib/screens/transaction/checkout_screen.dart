import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;
  const CheckoutScreen({super.key, required this.farmer});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<dynamic> _products = [];
  Map<int, int> _cart = {};
  String _paymentMethod = 'cash';
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await ApiService.get('/products');
    if (response.statusCode == 200) {
      setState(() {
        _products = jsonDecode(response.body);
        _isLoading = false;
      });
    }
  }

  double get _total {
    double total = 0;
    _cart.forEach((productId, qty) {
      final product = _products.firstWhere((p) => p['id'] == productId);
      total += product['price_fcfa'] * qty;
    });
    return total;
  }

  double get _totalWithInterest {
    return _paymentMethod == 'credit' ? _total * 1.3 : _total;
  }

  Future<void> _submitOrder() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez des produits'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final items = _cart.entries
        .map((e) => {'product_id': e.key, 'quantity': e.value})
        .toList();

    final response = await ApiService.post('/transactions', {
      'farmer_id': widget.farmer['id'],
      'payment_method': _paymentMethod,
      'items': items,
    });

    setState(() => _isSubmitting = false);

    if (response.statusCode == 201 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande créée avec succès !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Erreur'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande - ${widget.farmer['firstname']}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final qty = _cart[product['id']] ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(product['name']),
                          subtitle: Text('${product['price_fcfa']} FCFA'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: qty > 0
                                    ? () => setState(() {
                                          if (qty == 1) {
                                            _cart.remove(product['id']);
                                          } else {
                                            _cart[product['id']] = qty - 1;
                                          }
                                        })
                                    : null,
                              ),
                              Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => _cart[product['id']] = qty + 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Résumé et paiement
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, -2))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mode de paiement :'),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'cash',
                                groupValue: _paymentMethod,
                                onChanged: (v) => setState(() => _paymentMethod = v!),
                              ),
                              const Text('Cash'),
                              Radio<String>(
                                value: 'credit',
                                groupValue: _paymentMethod,
                                onChanged: (v) => setState(() => _paymentMethod = v!),
                              ),
                              const Text('Crédit'),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total :'),
                          Text('${_total.toStringAsFixed(0)} FCFA'),
                        ],
                      ),
                      if (_paymentMethod == 'credit') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Avec intérêts (30%) :'),
                            Text(
                              '${_totalWithInterest.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Confirmer la commande', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}