class CryptoCoin {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double priceChange24h;
  final double marketCap;

  CryptoCoin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChange24h,
    required this.marketCap,
  });

  factory CryptoCoin.fromJson(Map<String, dynamic> json) {
    return CryptoCoin(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toUpperCase(),
      name: json['name'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      priceChange24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
    );
  }
}

class PortfolioItem {
  final String coinId;
  final String symbol;
  final String name;
  final double amount;
  final double buyPrice;
  final DateTime addedAt;

  PortfolioItem({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.buyPrice,
    required this.addedAt,
  });

  double get currentValue => amount * buyPrice;
  
  double calculateProfit(double currentPrice) {
    return (currentPrice - buyPrice) * amount;
  }

  double calculateProfitPercent(double currentPrice) {
    if (buyPrice == 0) return 0;
    return ((currentPrice - buyPrice) / buyPrice) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'symbol': symbol,
      'name': name,
      'amount': amount,
      'buyPrice': buyPrice,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      coinId: json['coinId'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      buyPrice: (json['buyPrice'] ?? 0).toDouble(),
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}
