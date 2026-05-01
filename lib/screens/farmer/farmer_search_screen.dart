import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'farmer_detail_screen.dart';
import 'create_farmer_screen.dart';

class FarmerSearchScreen extends StatefulWidget {
  const FarmerSearchScreen({super.key});

  @override
  State<FarmerSearchScreen> createState() => _FarmerSearchScreenState();
}

class _FarmerSearchScreenState extends State<FarmerSearchScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _farmer;
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    setState(() { _isLoading = true; _error = null; });

    final response = await ApiService.get('/farmers/search?q=${_searchController.text.trim()}');

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      setState(() => _farmer = jsonDecode(response.body));
    } else {
      setState(() => _error = 'Fermier non trouvé');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher Fermier'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Identifiant ou téléphone',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            if (_farmer != null)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text('${_farmer!['firstname']} ${_farmer!['lastname']}'),
                  subtitle: Text('ID: ${_farmer!['identifier']} • Tél: ${_farmer!['phone']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FarmerDetailScreen(farmer: _farmer!),
                  )),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CreateFarmerScreen(),
                )),
                icon: const Icon(Icons.person_add),
                label: const Text('Créer un nouveau fermier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}