//
//  CoinGeckoService.swift
//  CryptoTracker
//
//  Сервис для работы с CoinGecko API
//

import Foundation

class CoinGeckoService {
    static let shared = CoinGeckoService()
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    private init() {}
    
    func fetchTopCoins(limit: Int = 50) async throws -> [Coin] {
        let urlString = "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(limit)&page=1&sparkline=false"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let coins = try JSONDecoder().decode([Coin].self, from: data)
            return coins
        } catch {
            throw error
        }
    }
    
    func fetchCoinPrice(coinId: String) async throws -> Double {
        let urlString = "\(baseURL)/simple/price?ids=\(coinId)&vs_currencies=usd"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Double]]
        return json?[coinId]?["usd"] ?? 0.0
    }
}
