import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await ApiService.get('/categories');
    if (response.statusCode == 200) {
      setState(() {
        _categories = jsonDecode(response.body);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue Produits'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: Icon(Icons.category, color: Colors.green.shade700),
                    title: Text(
                      category['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      if (category['children'] != null)
                        ...List.generate(
                          (category['children'] as List).length,
                          (i) {
                            final sub = category['children'][i];
                            return ExpansionTile(
                              leading: const Icon(Icons.subdirectory_arrow_right),
                              title: Text(sub['name']),
                              children: [
                                if (sub['children'] != null)
                                  ...List.generate(
                                    (sub['children'] as List).length,
                                    (j) {
                                      final subSub = sub['children'][j];
                                      return ListTile(
                                        leading: const Icon(Icons.circle, size: 10),
                                        title: Text(subSub['name']),
                                      );
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}