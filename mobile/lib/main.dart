import 'package:flutter/material.dart';

import 'models/item.dart';
import 'services/api_service.dart';

void main() {
  runApp(const CartlyApp());
}

class CartlyApp extends StatelessWidget {
  const CartlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cartly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const ShoppingListPage(),
    );
  }
}

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final ApiService _apiService = ApiService();

  final TextEditingController _userIdController =
      TextEditingController(text: 'user-1');

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  List<Item> _items = [];

  bool _isLoading = false;
  bool _isSubmitting = false;

  String? _errorMessage;

  String get _userId => _userIdController.text.trim();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (_userId.isEmpty) {
      setState(() {
        _errorMessage = 'User ID is required.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _apiService.getItems(_userId);

      if (!mounted) return;

      setState(() {
        _items = items;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(
      _quantityController.text.trim(),
    );

    if (_userId.isEmpty) {
      _showMessage('User ID is required.');
      return;
    }

    if (name.isEmpty) {
      _showMessage('Item name is required.');
      return;
    }

    if (quantity == null || quantity < 1) {
      _showMessage('Quantity must be at least 1.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.createItem(
        _userId,
        name,
        quantity,
      );

      _nameController.clear();
      _quantityController.text = '1';

      await _loadItems();

      if (!mounted) return;

      _showMessage('Item added successfully.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _toggleBought(Item item) async {
    try {
      await _apiService.toggleBought(
        _userId,
        item.id,
      );

      await _loadItems();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _deleteItem(Item item) async {
    try {
      await _apiService.deleteItem(
        _userId,
        item.id,
      );

      await _loadItems();

      if (!mounted) return;

      _showMessage('${item.name} deleted.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _clearBought() async {
    try {
      final deletedCount = await _apiService.clearBought(
        _userId,
      );

      await _loadItems();

      if (!mounted) return;

      if (deletedCount == 0) {
        _showMessage('No bought items to clear.');
      } else {
        _showMessage(
          '$deletedCount bought item(s) cleared.',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final boughtCount =
        _items.where((item) => item.bought).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartly'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadItems,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Shopping List',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add and manage your shopping items.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Example: user-1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSubmitted: (_) => _loadItems(),
              ),

              const SizedBox(height: 12),

              FilledButton.icon(
                onPressed: _isLoading ? null : _loadItems,
                icon: const Icon(Icons.login),
                label: const Text('Load User List'),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item name',
                          hintText: 'Example: Milk',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              _isSubmitting ? null : _addItem,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: Text(
                            _isSubmitting
                                ? 'Adding...'
                                : 'Add Item',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Items (${_items.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        boughtCount == 0 ? null : _clearBought,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clear Bought'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadItems,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your shopping list is empty.',
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Checkbox(
                        value: item.bought,
                        onChanged: (_) => _toggleBought(item),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: item.bought
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        'Quantity: ${item.quantity}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _deleteItem(item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}