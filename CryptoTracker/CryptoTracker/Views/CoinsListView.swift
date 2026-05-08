//
//  CoinsListView.swift
//  CryptoTracker
//
//  Экран списка криптовалют
//

import SwiftUI

struct CoinsListView: View {
    @StateObject private var viewModel = CoinsViewModel()
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var showingAddSheet = false
    @State private var selectedCoin: Coin?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.coins.isEmpty {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Попробовать снова") {
                            Task {
                                await viewModel.fetchCoins()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.coins) { coin in
                            CoinRowView(coin: coin)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCoin = coin
                                    showingAddSheet = true
                                }
                        }
                    }
                    .refreshable {
                        await viewModel.refreshCoins()
                        await portfolioManager.updateCurrentPrices()
                    }
                }
            }
            .navigationTitle("Криптовалюты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refreshCoins()
                            await portfolioManager.updateCurrentPrices()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                if let coin = selectedCoin {
                    AddToPortfolioView(coin: coin, isPresented: $showingAddSheet)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchCoins()
                }
            }
        }
    }
}

struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatPrice(coin.currentPrice))
                    .font(.headline)
                
                if let change = coin.priceChangePercentage24h {
                    Text(String(format: "%+.2f%%", change))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price >= 1 {
            return String(format: "$%.2f", price)
        } else if price >= 0.01 {
            return String(format: "$%.4f", price)
        } else {
            return String(format: "$%.8f", price)
        }
    }
}

#Preview {
    CoinsListView()
        .environmentObject(PortfolioManager.shared)
}
