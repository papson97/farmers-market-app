import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DebtScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;
  const DebtScreen({super.key, required this.farmer});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  Map<String, dynamic>? _debtData;
  bool _isLoading = true;
  final _kgController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final response = await ApiService.get('/farmers/${widget.farmer['id']}/debts');
    if (response.statusCode == 200) {
      setState(() {
        _debtData = jsonDecode(response.body);
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRepayment() async {
    final kg = double.tryParse(_kgController.text);
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un nombre de kg valide'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await ApiService.post('/repayments', {
      'farmer_id': widget.farmer['id'],
      'kg_received': kg,
    });

    setState(() => _isSubmitting = false);

    if (response.statusCode == 201 && mounted) {
      _kgController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remboursement enregistré !'), backgroundColor: Colors.green),
      );
      _loadDebts();
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
        title: Text('Dettes - ${widget.farmer['firstname']}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dette totale :', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${_debtData!['total_debt']} FCFA',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Liste des dettes
                  const Text('Dettes ouvertes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if ((_debtData!['debts'] as List).isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aucune dette en cours'),
                      ),
                    )
                  else
                    ...(_debtData!['debts'] as List).map((debt) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              debt['status'] == 'partial' ? Icons.hourglass_bottom : Icons.warning,
                              color: Colors.orange,
                            ),
                            title: Text('${debt['remaining_fcfa']} FCFA restants'),
                            subtitle: Text('Total initial: ${debt['amount_fcfa']} FCFA • ${debt['status']}'),
                          ),
                        )),
                  const SizedBox(height: 24),
                  // Remboursement
                  const Text('Enregistrer un remboursement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _kgController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Kg de cacao reçus',
                            prefixIcon: const Icon(Icons.scale),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRepayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}