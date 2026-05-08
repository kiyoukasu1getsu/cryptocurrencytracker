//
//  PortfolioManager.swift
//  CryptoTracker
//
//  Управление портфелем криптовалют
//

import Foundation
import SwiftUI

class PortfolioManager: ObservableObject {
    static let shared = PortfolioManager()
    
    @Published var portfolioItems: [PortfolioItem] = []
    @Published var currentPrices: [String: Double] = [:]
    
    private let saveKey = "PortfolioItems"
    
    private init() {
        loadPortfolio()
        Task {
            await updateCurrentPrices()
        }
    }
    
    func addItem(coin: Coin, amount: Double, buyPrice: Double) {
        let newItem = PortfolioItem(
            id: UUID(),
            coinId: coin.id,
            symbol: coin.symbol,
            name: coin.name,
            amount: amount,
            buyPrice: buyPrice,
            dateAdded: Date()
        )
        
        portfolioItems.append(newItem)
        savePortfolio()
    }
    
    func updateItem(_ item: PortfolioItem) {
        if let index = portfolioItems.firstIndex(where: { $0.id == item.id }) {
            portfolioItems[index] = item
            savePortfolio()
        }
    }
    
    func deleteItem(_ item: PortfolioItem) {
        portfolioItems.removeAll { $0.id == item.id }
        savePortfolio()
    }
    
    func deleteItems(at offsets: IndexSet) {
        portfolioItems.remove(atOffsets: offsets)
        savePortfolio()
    }
    
    func getPortfolioSummary() -> (totalValue: Double, investedAmount: Double, profitLoss: Double, profitLossPercentage: Double) {
        var totalValue = 0.0
        var investedAmount = 0.0
        
        for item in portfolioItems {
            let currentPrice = currentPrices[item.coinId] ?? item.buyPrice
            totalValue += item.amount * currentPrice
            investedAmount += item.amount * item.buyPrice
        }
        
        let profitLoss = totalValue - investedAmount
        let profitLossPercentage = investedAmount > 0 ? (profitLoss / investedAmount) * 100 : 0
        
        return (totalValue, investedAmount, profitLoss, profitLossPercentage)
    }
    
    func getCurrentValue(for item: PortfolioItem) -> Double {
        let currentPrice = currentPrices[item.coinId] ?? item.buyPrice
        return item.amount * currentPrice
    }
    
    func getProfitLoss(for item: PortfolioItem) -> Double {
        let currentValue = getCurrentValue(for: item)
        return currentValue - item.totalValue
    }
    
    func getProfitLossPercentage(for item: PortfolioItem) -> Double {
        let profitLoss = getProfitLoss(for: item)
        return item.totalValue > 0 ? (profitLoss / item.totalValue) * 100 : 0
    }
    
    func updateCurrentPrices() async {
        guard !portfolioItems.isEmpty else { return }
        
        let coinIds = Set(portfolioItems.map { $0.coinId }).joined(separator: ",")
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinIds)&vs_currencies=usd"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Double]]
            
            DispatchQueue.main.async {
                self.currentPrices.removeAll()
                for (coinId, prices) in json ?? [:] {
                    if let usdPrice = prices["usd"] {
                        self.currentPrices[coinId] = usdPrice
                    }
                }
            }
        } catch {
            print("Error updating prices: \(error)")
        }
    }
    
    private func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(portfolioItems) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadPortfolio() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let items = try? JSONDecoder().decode([PortfolioItem].self, from: data) {
            portfolioItems = items
        }
    }
}
