import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/store.dart';

class NewOrderDialog extends StatefulWidget {
  final Future<void> Function({
    required String storeId,
    required Map<String, dynamic> details,
  })
  onCreateOrder;

  const NewOrderDialog({super.key, required this.onCreateOrder});

  @override
  State<NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<NewOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  Store _selectedStore = Stores.cocoBambuLojaTeste;

  // Customer fields
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  // Delivery address fields
  final _streetNameController = TextEditingController();
  final _streetNumberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _referenceController = TextEditingController();

  // Payment fields
  String _paymentMethod = 'CREDIT_CARD';
  bool _isPrepaid = true;

  final List<OrderItem> _items = [OrderItem()];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _streetNameController.dispose();
    _streetNumberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _referenceController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double _calculateTotal() {
    return _items.fold(0.0, (sum, item) {
      final quantity = int.tryParse(item.quantityController.text) ?? 0;
      final price = double.tryParse(item.priceController.text) ?? 0.0;
      return sum + (quantity * price);
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return AlertDialog(
      title: const Text('Novo Pedido'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Store Dropdown
                DropdownButtonFormField<Store>(
                  initialValue: _selectedStore,
                  decoration: const InputDecoration(
                    labelText: 'Loja',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                  items: Stores.all.map((store) {
                    return DropdownMenuItem<Store>(
                      value: store,
                      child: Text(store.name),
                    );
                  }).toList(),
                  onChanged: (Store? newStore) {
                    if (newStore != null) {
                      setState(() {
                        _selectedStore = newStore;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione uma loja';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Customer Section
                const Text(
                  'Informações do Cliente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Cliente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    isDense: true,
                    hintText: 'Nome',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    isDense: true,
                    hintText: '+5561999999999',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefone obrigatório';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Delivery Address Section
                const Text(
                  'Endereço de Entrega',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _streetNameController,
                        decoration: const InputDecoration(
                          labelText: 'Rua',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'Avenida das Pitangueiras',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _streetNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Número',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: '123',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _neighborhoodController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: 'Asa Sul',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bairro obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'Brasília',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'DF',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: '70.000-000',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CEP obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Ponto de Referência (opcional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: 'Próximo ao mercado',
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                // Payment Section
                const Text(
                  'Pagamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Método de Pagamento',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'CREDIT_CARD',
                            child: Text('Cartão de Crédito'),
                          ),
                          DropdownMenuItem(
                            value: 'DEBIT_CARD',
                            child: Text('Cartão de Débito'),
                          ),
                          DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                          DropdownMenuItem(
                            value: 'CASH',
                            child: Text('Dinheiro'),
                          ),
                          DropdownMenuItem(
                            value: 'VR',
                            child: Text('Vale Refeição'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _paymentMethod = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _isPrepaid,
                          onChanged: (value) {
                            setState(() {
                              _isPrepaid = value ?? true;
                            });
                          },
                          activeColor: Colors.green.shade600,
                        ),
                        const Text('Pago'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Items Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Itens do Pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _items.add(OrderItem());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Item'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Items List
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_items.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      item.dispose();
                                      _items.removeAt(index);
                                    });
                                  },
                                  color: Colors.red,
                                  tooltip: 'Remover item',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: item.nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              border: OutlineInputBorder(),
                              isDense: true,
                              hintText: 'Pizza Margherita',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nome obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.quantityController,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantidade',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Obrigatório';
                                    }
                                    final qty = int.tryParse(value);
                                    if (qty == null || qty <= 0) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: item.priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Preço (R\$)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    hintText: '45.90',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Obrigatório';
                                    }
                                    final price = double.tryParse(value);
                                    if (price == null || price <= 0) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: item.observationsController,
                            decoration: const InputDecoration(
                              labelText: 'Observações (opcional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              hintText: 'Sem cebola, bem passada',
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Total Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total do Pedido:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_isSubmitting ? 'Criando...' : 'Novo Pedido'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final total = _calculateTotal();
      final items = _items.map((item) {
        final quantity = int.parse(item.quantityController.text);
        final price = double.parse(item.priceController.text);
        return {
          'name': item.nameController.text,
          'quantity': quantity,
          'price': price,
          'total_price': quantity * price,
          'discount': 0,
          if (item.observationsController.text.isNotEmpty)
            'observations': item.observationsController.text,
          'condiments': [],
        };
      }).toList();

      final details = {
        'items': items,
        'total_price': total,
        'customer': {
          'name': _customerNameController.text,
          'temporary_phone': _customerPhoneController.text,
        },
        'delivery_address': {
          'street_name': _streetNameController.text,
          'street_number': _streetNumberController.text,
          'neighborhood': _neighborhoodController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postal_code': _postalCodeController.text,
          'country': 'BR',
          if (_referenceController.text.isNotEmpty)
            'reference': _referenceController.text,
        },
        'payments': [
          {'value': total, 'origin': _paymentMethod, 'prepaid': _isPrepaid},
        ],
        'store': {'id': _selectedStore.id, 'name': _selectedStore.name},
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      await widget.onCreateOrder(storeId: _selectedStore.id, details: details);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class OrderItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController priceController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    observationsController.dispose();
  }
}
