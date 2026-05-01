import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateFarmerScreen extends StatefulWidget {
  const CreateFarmerScreen({super.key});

  @override
  State<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends State<CreateFarmerScreen> {
  final _identifierController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _creditLimitController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createFarmer() async {
    setState(() => _isLoading = true);

    final response = await ApiService.post('/farmers', {
      'identifier': _identifierController.text.trim(),
      'firstname': _firstnameController.text.trim(),
      'lastname': _lastnameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'credit_limit_fcfa': double.tryParse(_creditLimitController.text) ?? 0,
    });

    setState(() => _isLoading = false);

    if (response.statusCode == 201 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fermier créé avec succès'), backgroundColor: Colors.green),
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
        title: const Text('Nouveau Fermier'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField(_identifierController, 'Identifiant (carte)', Icons.badge),
            const SizedBox(height: 12),
            _buildField(_firstnameController, 'Prénom', Icons.person),
            const SizedBox(height: 12),
            _buildField(_lastnameController, 'Nom', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(_phoneController, 'Téléphone', Icons.phone, type: TextInputType.phone),
            const SizedBox(height: 12),
            _buildField(_creditLimitController, 'Limite de crédit (FCFA)', Icons.credit_card, type: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createFarmer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Créer le fermier', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}