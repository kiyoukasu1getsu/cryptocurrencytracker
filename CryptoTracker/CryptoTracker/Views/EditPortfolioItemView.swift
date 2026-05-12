//
//  EditPortfolioItemView.swift
//  CryptoTracker
//
//  Created on 08.05.2024.
//

import SwiftUI

// MARK: - Edit Portfolio Item View

/// View for editing a portfolio item
struct EditPortfolioItemView: View {
    let item: PortfolioItem
    @Binding var isPresented: Bool
    @EnvironmentObject var portfolioManager: PortfolioManager
    
    @State private var amount: String
    @State private var buyPrice: String
    
    init(item: PortfolioItem, isPresented: Binding<Bool>) {
        self.item = item
        self._isPresented = isPresented
        self._amount = State(initialValue: String(format: "%.8f", item.amount))
        self._buyPrice = State(initialValue: String(format: "%.2f", item.buyPrice))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coin")) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        Spacer()
                        Text(item.symbol.uppercased())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Date Added:")
                        Spacer()
                        Text(formatDate(item.dateAdded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Edit Details")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Buy Price per Coin ($)", text: $buyPrice)
                        .keyboardType(.decimalPad)
                    
                    if !amount.isEmpty && !buyPrice.isEmpty,
                       let amountValue = Double(amount),
                       let priceValue = Double(buyPrice),
                       amountValue > 0, priceValue > 0 {
                        HStack {
                            Text("Total Cost:")
                            Spacer()
                            Text(formatPrice(amountValue * priceValue))
                                .fontWeight(.semibold)
                        }
                        
                        let currentValue = portfolioManager.getCurrentValue(for: item)
                        let newProfitLoss = (amountValue * currentValue) - (amountValue * priceValue)
                        
                        HStack {
                            Text("Profit/Loss:")
                            Spacer()
                            Text(formatPrice(newProfitLoss))
                                .fontWeight(.semibold)
                                .foregroundColor(newProfitLoss >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValidInput)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        deleteItem()
                    } label: {
                        Label("Delete Position", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var isValidInput: Bool {
        guard !amount.isEmpty, !buyPrice.isEmpty else { return false }
        guard let amountValue = Double(amount), let priceValue = Double(buyPrice) else { return false }
        return amountValue > 0 && priceValue > 0
    }
    
    // MARK: - Private Methods
    
    private func saveChanges() {
        guard let amountValue = Double(amount),
              let priceValue = Double(buyPrice),
              amountValue > 0, priceValue > 0 else { return }
        
        var updatedItem = item
        updatedItem.amount = amountValue
        updatedItem.buyPrice = priceValue
        
        portfolioManager.updateItem(updatedItem)
        isPresented = false
    }
    
    private func deleteItem() {
        portfolioManager.deleteItem(item)
        isPresented = false
    }
    
    private func formatPrice(_ price: Double) -> String {
        return String(format: "$%.2f", price)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    EditPortfolioItemView(
        item: PortfolioItem(
            id: UUID(),
            coinId: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            amount: 0.5,
            buyPrice: 45000.0,
            dateAdded: Date()
        ),
        isPresented: .constant(true)
    )
    .environmentObject(PortfolioManager.shared)
}
