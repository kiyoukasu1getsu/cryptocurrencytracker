//
//  Coin.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import Foundation

// MARK: - Coin Model

/// Represents a cryptocurrency with its market data
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

// MARK: - Portfolio Item Model

/// Represents a cryptocurrency holding in the user's portfolio
struct PortfolioItem: Codable, Identifiable {
    let id: UUID
    var coinId: String
    var symbol: String
    var name: String
    var amount: Double
    var buyPrice: Double
    var dateAdded: Date
    
    /// Total value at purchase (amount * buyPrice)
    var totalValue: Double {
        return amount * buyPrice
    }
}
