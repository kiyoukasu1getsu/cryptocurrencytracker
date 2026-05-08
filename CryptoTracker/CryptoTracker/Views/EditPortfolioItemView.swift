//
//  EditPortfolioItemView.swift
//  CryptoTracker
//
//  Экран редактирования позиции в портфеле
//

import SwiftUI

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
                Section(header: Text("Монета")) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        Spacer()
                        Text(item.symbol.uppercased())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Дата добавления:")
                        Spacer()
                        Text(formatDate(item.dateAdded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Изменить данные")) {
                    TextField("Количество", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Цена покупки за 1 монету ($)", text: $buyPrice)
                        .keyboardType(.decimalPad)
                    
                    if !amount.isEmpty && !buyPrice.isEmpty,
                       let amountValue = Double(amount),
                       let priceValue = Double(buyPrice),
                       amountValue > 0, priceValue > 0 {
                        HStack {
                            Text("Общая стоимость:")
                            Spacer()
                            Text(formatPrice(amountValue * priceValue))
                                .fontWeight(.semibold)
                        }
                        
                        let currentValue = portfolioManager.getCurrentValue(for: item)
                        let newProfitLoss = (amountValue * currentValue) - (amountValue * priceValue)
                        
                        HStack {
                            Text("Прибыль/Убыток:")
                            Spacer()
                            Text(formatPrice(newProfitLoss))
                                .fontWeight(.semibold)
                                .foregroundColor(newProfitLoss >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("Редактировать")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .disabled(!isValidInput)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        deleteItem()
                    } label: {
                        Label("Удалить позицию", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        guard !amount.isEmpty, !buyPrice.isEmpty else { return false }
        guard let amountValue = Double(amount), let priceValue = Double(buyPrice) else { return false }
        return amountValue > 0 && priceValue > 0
    }
    
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
