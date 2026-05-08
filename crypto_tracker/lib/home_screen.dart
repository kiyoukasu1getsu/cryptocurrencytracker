import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'portfolio_provider.dart';
import 'models.dart';
import 'add_to_portfolio_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PortfolioProvider>().refreshCoins();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _CoinsListScreen(),
          _PortfolioScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Prices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
        ],
      ),
    );
  }
}

class _CoinsListScreen extends StatelessWidget {
  const _CoinsListScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadCoins(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.coins.isEmpty) {
          return const Center(child: Text('No coins available'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshCoins(),
          child: ListView.builder(
            itemCount: provider.coins.length,
            itemBuilder: (context, index) {
              final coin = provider.coins[index];
              return _CoinTile(coin: coin);
            },
          ),
        );
      },
    );
  }
}

class _CoinTile extends StatelessWidget {
  final CryptoCoin coin;

  const _CoinTile({required this.coin});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChange24h >= 0;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          coin.symbol.substring(0, 1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ),
      title: Text(coin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(coin.symbol),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice < 1 ? 6 : 2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 20,
              ),
              Text(
                '${isPositive ? '+' : ''}${coin.priceChange24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AddToPortfolioDialog(coin: coin),
        );
      },
    );
  }
}

class _PortfolioScreen extends StatelessWidget {
  const _PortfolioScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        if (provider.portfolio.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Your portfolio is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap on any coin to add it to your portfolio',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Portfolio Value',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${provider.totalPortfolioValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'Invested',
                        '\$${provider.totalInvested.toStringAsFixed(2)}',
                        Colors.white70,
                      ),
                      _buildStatCard(
                        'Profit/Loss',
                        '${provider.totalProfit >= 0 ? '+' : ''}\$${provider.totalProfit.toStringAsFixed(2)}',
                        provider.totalProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
                      ),
                      _buildStatCard(
                        'Return',
                        '${provider.totalProfitPercent >= 0 ? '+' : ''}${provider.totalProfitPercent.toStringAsFixed(2)}%',
                        provider.totalProfitPercent >= 0 ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.portfolio.length,
                itemBuilder: (context, index) {
                  final item = provider.portfolio[index];
                  final currentPrice = provider.getCurrentPrice(item.coinId);
                  final profit = item.calculateProfit(currentPrice);
                  final profitPercent = item.calculateProfitPercent(currentPrice);
                  final isPositive = profit >= 0;

                  return Dismissible(
                    key: Key(item.coinId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      provider.removeFromPortfolio(item.coinId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.symbol} removed from portfolio')),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          item.symbol.substring(0, 1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.amount.toStringAsFixed(6)} ${item.symbol}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(item.amount * currentPrice).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${isPositive ? '+' : ''}${profit.toStringAsFixed(2)} (${isPositive ? '+' : ''}${profitPercent.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color: isPositive ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddToPortfolioDialog(
                            coin: CryptoCoin(
                              id: item.coinId,
                              symbol: item.symbol,
                              name: item.name,
                              currentPrice: currentPrice,
                              priceChange24h: 0,
                              marketCap: 0,
                            ),
                            existingItem: item,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
