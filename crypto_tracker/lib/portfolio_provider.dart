import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'api_service.dart';

class PortfolioProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CryptoCoin> _coins = [];
  List<PortfolioItem> _portfolio = [];
  bool _isLoading = false;
  String? _error;

  List<CryptoCoin> get coins => _coins;
  List<PortfolioItem> get portfolio => _portfolio;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalPortfolioValue {
    double total = 0;
    for (var item in _portfolio) {
      final coin = _coins.firstWhere((c) => c.id == item.coinId, orElse: () => 
        CryptoCoin(id: '', symbol: '', name: '', currentPrice: 0, priceChange24h: 0, marketCap: 0)
      );
      total += item.amount * coin.currentPrice;
    }
    return total;
  }

  double get totalInvested {
    return _portfolio.fold(0, (sum, item) => sum + item.currentValue);
  }

  double get totalProfit => totalPortfolioValue - totalInvested;

  double get totalProfitPercent {
    if (totalInvested == 0) return 0;
    return (totalProfit / totalInvested) * 100;
  }

  Future<void> loadCoins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coins = await _apiService.getTopCoins();
      await _loadPortfolio();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCoins() async {
    await loadCoins();
  }

  Future<void> _loadPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfolioJson = prefs.getString('portfolio');
      if (portfolioJson != null) {
        final List<dynamic> decoded = json.decode(portfolioJson);
        _portfolio = decoded.map((item) => PortfolioItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
    }
    notifyListeners();
  }

  Future<void> _savePortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfolioJson = json.encode(_portfolio.map((item) => item.toJson()).toList());
      await prefs.setString('portfolio', portfolioJson);
    } catch (e) {
      debugPrint('Error saving portfolio: $e');
    }
  }

  void addToPortfolio(String coinId, String symbol, String name, double amount, double buyPrice) {
    final existingIndex = _portfolio.indexWhere((item) => item.coinId == coinId);
    
    if (existingIndex >= 0) {
      final existing = _portfolio[existingIndex];
      final totalAmount = existing.amount + amount;
      final avgPrice = ((existing.amount * existing.buyPrice) + (amount * buyPrice)) / totalAmount;
      
      _portfolio[existingIndex] = PortfolioItem(
        coinId: coinId,
        symbol: symbol,
        name: name,
        amount: totalAmount,
        buyPrice: avgPrice,
        addedAt: existing.addedAt,
      );
    } else {
      _portfolio.add(PortfolioItem(
        coinId: coinId,
        symbol: symbol,
        name: name,
        amount: amount,
        buyPrice: buyPrice,
        addedAt: DateTime.now(),
      ));
    }
    
    _savePortfolio();
    notifyListeners();
  }

  void removeFromPortfolio(String coinId) {
    _portfolio.removeWhere((item) => item.coinId == coinId);
    _savePortfolio();
    notifyListeners();
  }

  void updatePortfolioAmount(String coinId, double newAmount) {
    final index = _portfolio.indexWhere((item) => item.coinId == coinId);
    if (index >= 0 && newAmount > 0) {
      final item = _portfolio[index];
      _portfolio[index] = PortfolioItem(
        coinId: item.coinId,
        symbol: item.symbol,
        name: item.name,
        amount: newAmount,
        buyPrice: item.buyPrice,
        addedAt: item.addedAt,
      );
      _savePortfolio();
      notifyListeners();
    }
  }

  double getCurrentPrice(String coinId) {
    final coin = _coins.firstWhere((c) => c.id == coinId, orElse: () => 
      CryptoCoin(id: '', symbol: '', name: '', currentPrice: 0, priceChange24h: 0, marketCap: 0)
    );
    return coin.currentPrice;
  }
}
