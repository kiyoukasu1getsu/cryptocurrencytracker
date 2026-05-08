import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'portfolio_provider.dart';
import 'models.dart';

class AddToPortfolioDialog extends StatefulWidget {
  final CryptoCoin coin;
  final PortfolioItem? existingItem;

  const AddToPortfolioDialog({
    super.key,
    required this.coin,
    this.existingItem,
  });

  @override
  State<AddToPortfolioDialog> createState() => _AddToPortfolioDialogState();
}

class _AddToPortfolioDialogState extends State<AddToPortfolioDialog> {
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingItem != null;
    
    if (widget.existingItem != null) {
      _amountController.text = widget.existingItem!.amount.toString();
      _priceController.text = widget.existingItem!.buyPrice.toStringAsFixed(6);
    } else {
      _priceController.text = widget.coin.currentPrice.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PortfolioProvider>();
    
    return AlertDialog(
      title: Text(_isEditing ? 'Edit ${widget.coin.symbol}' : 'Add ${widget.coin.symbol}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.coin.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            if (_isEditing) ...[
              Text(
                'Current Price: \$${widget.coin.currentPrice.toStringAsFixed(widget.coin.currentPrice < 1 ? 6 : 2)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (${widget.coin.symbol})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Buy Price (USD)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            if (!_isEditing && widget.existingItem == null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final amount = double.tryParse(_amountController.text) ?? 0;
                        final price = double.tryParse(_priceController.text) ?? 0;
                        final total = amount * price;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount: ${amount.toStringAsFixed(6)} ${widget.coin.symbol}'),
                            Text('Price: \$${price.toStringAsFixed(6)}'),
                            Text('Total: \$${total.toStringAsFixed(2)}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove from Portfolio'),
                  content: const Text('Are you sure you want to remove this coin from your portfolio?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.removeFromPortfolio(widget.coin.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            final price = double.tryParse(_priceController.text);
            
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
              return;
            }
            
            if (price == null || price <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid price')),
              );
              return;
            }
            
            provider.addToPortfolio(
              widget.coin.id,
              widget.coin.symbol,
              widget.coin.name,
              amount,
              price,
            );
            
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_isEditing ? 'Updated' : 'Added'} ${widget.coin.symbol} to portfolio'),
              ),
            );
          },
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
