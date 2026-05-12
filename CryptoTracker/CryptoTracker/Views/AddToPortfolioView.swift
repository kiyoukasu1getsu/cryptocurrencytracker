//
//  AddToPortfolioView.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import SwiftUI

// MARK: - Add to Portfolio View

/// View for adding a cryptocurrency to the portfolio
struct AddToPortfolioView: View {
    let coin: Coin
    @Binding var isPresented: Bool
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    @State private var amount: String = ""
    @State private var buyPrice: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coin Information")) {
                    HStack {
                        AsyncImage(url: URL(string: coin.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(coin.name)
                                .font(.headline)
                            Text(coin.symbol.uppercased())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Current Price:")
                        Spacer()
                        Text(formatPrice(coin.currentPrice))
                            .fontWeight(.semibold)
                    }
                }
                
                Section(header: Text("Purchase Details")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Buy Price per Coin ($)", text: $buyPrice)
                        .keyboardType(.decimalPad)
                    
                    if !amount.isEmpty && !buyPrice.isEmpty,
                       let amountValue = Double(amount),
                       let priceValue = Double(buyPrice),
                       amountValue > 0, priceValue > 0 {
                        HStack {
                            Text("Total Cost:")
                            Spacer()
                            Text(formatPrice(amountValue * priceValue))
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section {
                    Text("Tip: Enter the actual purchase price to accurately track profit or loss.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add to Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addCoin()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var isValidInput: Bool {
        guard !amount.isEmpty, !buyPrice.isEmpty else { return false }
        guard let amountValue = Double(amount), let priceValue = Double(buyPrice) else { return false }
        return amountValue > 0 && priceValue > 0
    }
    
    // MARK: - Private Methods
    
    private func addCoin() {
        guard let amountValue = Double(amount),
              let priceValue = Double(buyPrice),
              amountValue > 0, priceValue > 0 else { return }
        
        portfolioManager.addItem(coin: coin, amount: amountValue, buyPrice: priceValue)
        isPresented = false
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
    AddToPortfolioView(
        coin: Coin(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            currentPrice: 45000.0,
            priceChangePercentage24h: 2.5,
            image: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png"
        ),
        isPresented: .constant(true)
    )
    .environmentObject(PortfolioManager.shared)
}
