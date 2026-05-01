import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../transaction/checkout_screen.dart';
import '../debt/debt_screen.dart';

class FarmerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;
  const FarmerDetailScreen({super.key, required this.farmer});

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
  Map<String, dynamic>? _farmerDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmerDetail();
  }

  Future<void> _loadFarmerDetail() async {
    final response = await ApiService.get('/farmers/${widget.farmer['id']}');
    if (response.statusCode == 200) {
      setState(() {
        _farmerDetail = jsonDecode(response.body);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = _farmerDetail ?? widget.farmer;

    return Scaffold(
      appBar: AppBar(
        title: Text('${farmer['firstname']} ${farmer['lastname']}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Info fermier
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green.shade700,
                            child: const Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${farmer['firstname']} ${farmer['lastname']}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _infoRow(Icons.badge, 'ID: ${farmer['identifier']}'),
                          _infoRow(Icons.phone, 'Tél: ${farmer['phone']}'),
                          _infoRow(Icons.credit_card, 'Limite crédit: ${farmer['credit_limit_fcfa']} FCFA'),
                          if (_farmerDetail?['total_debt'] != null)
                            _infoRow(
                              Icons.warning,
                              'Dette actuelle: ${_farmerDetail!['total_debt']} FCFA',
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckoutScreen(farmer: farmer)),
                      ),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Nouvelle commande', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DebtScreen(farmer: farmer)),
                      ),
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Voir les dettes', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}