//
//  CoinsViewModel.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import Foundation

// MARK: - Coins ViewModel

/// ViewModel for managing cryptocurrency list state
@MainActor
final class CoinsViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = CoinGeckoService.shared
    
    // MARK: - Public Methods
    
    /// Fetches the list of top cryptocurrencies
    func fetchCoins() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedCoins = try await service.fetchTopCoins(limit: 50)
            coins = fetchedCoins
        } catch {
            errorMessage = "Error loading data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Refreshes the cryptocurrency list
    func refreshCoins() async {
        await fetchCoins()
    }
}
