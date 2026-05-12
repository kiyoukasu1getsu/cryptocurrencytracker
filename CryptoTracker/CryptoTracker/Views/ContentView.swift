//
//  ContentView.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import SwiftUI

// MARK: - Content View

/// Main app view with tab navigation
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CoinsListView()
                .tabItem {
                    Label("Cryptocurrencies", systemImage: "list.bullet")
                }
                .tag(0)
            
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase.fill")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PortfolioManager.shared)
}
