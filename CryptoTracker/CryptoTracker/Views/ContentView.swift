//
//  ContentView.swift
//  CryptoTracker
//
//  Главный экран с навигацией
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CoinsListView()
                .tabItem {
                    Label("Криптовалюты", systemImage: "list.bullet")
                }
                .tag(0)
            
            PortfolioView()
                .tabItem {
                    Label("Портфель", systemImage: "briefcase.fill")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PortfolioManager.shared)
}
