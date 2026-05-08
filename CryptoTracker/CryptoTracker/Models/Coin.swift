//
//  Coin.swift
//  CryptoTracker
//
//  Модель криптовалюты
//

import Foundation

struct Coin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let priceChangePercentage24h: Double?
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case image
    }
}

struct PortfolioItem: Codable, Identifiable {
    let id: UUID
    var coinId: String
    var symbol: String
    var name: String
    var amount: Double
    var buyPrice: Double
    var dateAdded: Date
    
    var totalValue: Double {
        return amount * buyPrice
    }
}
