//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import SwiftUI

@main
struct CryptoTrackerApp: App {
    @StateObject private var portfolioManager = PortfolioManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(portfolioManager)
        }
    }
}
