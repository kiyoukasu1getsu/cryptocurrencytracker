//
//  CoinsViewModel.swift
//  CryptoTracker
//
//  ViewModel для списка криптовалют
//

import Foundation

@MainActor
class CoinsViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = CoinGeckoService.shared
    
    func fetchCoins() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedCoins = try await service.fetchTopCoins(limit: 50)
            coins = fetchedCoins
        } catch {
            errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshCoins() async {
        await fetchCoins()
    }
}
