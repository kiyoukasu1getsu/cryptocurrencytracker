//
//  AddToPortfolioView.swift
//  CryptoTracker
//
//  Экран добавления монеты в портфель
//

import SwiftUI

struct AddToPortfolioView: View {
    let coin: Coin
    @Binding var isPresented: Bool
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    @State private var amount: String = ""
    @State private var buyPrice: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о монете")) {
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
                        Text("Текущая цена:")
                        Spacer()
                        Text(formatPrice(coin.currentPrice))
                            .fontWeight(.semibold)
                    }
                }
                
                Section(header: Text("Данные покупки")) {
                    TextField("Количество", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Цена покупки за 1 монету ($)", text: $buyPrice)
                        .keyboardType(.decimalPad)
                    
                    if !amount.isEmpty && !buyPrice.isEmpty,
                       let amountValue = Double(amount),
                       let priceValue = Double(buyPrice),
                       amountValue > 0, priceValue > 0 {
                        HStack {
                            Text("Общая стоимость:")
                            Spacer()
                            Text(formatPrice(amountValue * priceValue))
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section {
                    Text("Совет: Укажите реальную цену покупки, чтобы точно отслеживать прибыль или убыток.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Добавить в портфель")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addCoin()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        guard !amount.isEmpty, !buyPrice.isEmpty else { return false }
        guard let amountValue = Double(amount), let priceValue = Double(buyPrice) else { return false }
        return amountValue > 0 && priceValue > 0
    }
    
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
    AddToPortfolioView(coin: Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", currentPrice: 45000.0, priceChangePercentage24h: 2.5, image: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png"), isPresented: .constant(true))
        .environmentObject(PortfolioManager.shared)
}
