//
//  PortfolioView.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import SwiftUI

// MARK: - Portfolio View

/// Displays the user's cryptocurrency portfolio with summary statistics
struct PortfolioView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var showingEditSheet = false
    @State private var selectedItem: PortfolioItem?
    
    var body: some View {
        NavigationView {
            Group {
                if portfolioManager.portfolioItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Your portfolio is empty")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add cryptocurrencies from the first section to start tracking your portfolio")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section(header: portfolioSummaryHeader) {
                            ForEach(portfolioManager.portfolioItems) { item in
                                PortfolioItemRow(item: item)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            portfolioManager.deleteItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .onTapGesture {
                                        selectedItem = item
                                        showingEditSheet = true
                                    }
                            }
                            .onDelete(perform: portfolioManager.deleteItems)
                        }
                    }
                }
            }
            .navigationTitle("Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await portfolioManager.updateCurrentPrices()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                if let item = selectedItem {
                    EditPortfolioItemView(item: item, isPresented: $showingEditSheet)
                }
            }
            .refreshable {
                await portfolioManager.updateCurrentPrices()
            }
        }
    }
    
    // MARK: - Private Views
    
    private var portfolioSummaryHeader: some View {
        let summary = portfolioManager.getPortfolioSummary()
        
        return Group {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatPrice(summary.totalValue))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Invested")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatPrice(summary.investedAmount))
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Profit/Loss")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(String(format: "%+.2f%%", summary.profitLossPercentage))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(formatPrice(summary.profitLoss))
                                    .font(.subheadline)
                            }
                            .foregroundColor(summary.profitLoss >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        return String(format: "$%.2f", price)
    }
}

// MARK: - Portfolio Item Row

/// Displays a single portfolio item row
struct PortfolioItemRow: View {
    let item: PortfolioItem
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(item.symbol.prefix(2).uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text("\(item.amount) \(item.symbol.uppercased())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let currentValue = portfolioManager.getCurrentValue(for: item)
                Text(formatPrice(currentValue))
                    .font(.headline)
                
                let profitLoss = portfolioManager.getProfitLoss(for: item)
                let profitLossPercentage = portfolioManager.getProfitLossPercentage(for: item)
                
                HStack {
                    Image(systemName: profitLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    Text(String(format: "%+.2f%%", profitLossPercentage))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(profitLoss >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatPrice(_ price: Double) -> String {
        return String(format: "$%.2f", price)
    }
}

#Preview {
    PortfolioView()
        .environmentObject(PortfolioManager.shared)
}
