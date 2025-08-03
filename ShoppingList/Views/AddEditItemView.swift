//
//  AddEditItemView.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import SwiftUI
import SwiftData

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ShoppingListViewModel
    
    let editingItem: Item?
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var note = ""
    
    init(viewModel: ShoppingListViewModel, editingItem: Item? = nil) {
        self.viewModel = viewModel
        self.editingItem = editingItem
        
        if let item = editingItem {
            _name = State(initialValue: item.name)
            _quantity = State(initialValue: item.quantity)
            _note = State(initialValue: item.note ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(editingItem != nil ? "Edit Item" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingItem != nil ? "Save" : "Add") {
                        Task {
                            if let item = editingItem {
                                await viewModel.updateItem(item, name: name, quantity: quantity, note: note.isEmpty ? nil : note)
                            } else {
                                await viewModel.addItem(name: name, quantity: quantity, note: note.isEmpty ? nil : note)
                            }
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddEditItemView(
        viewModel: ShoppingListViewModel(
            repository: MockRepository()
        )
    )
}

// MARK: - Preview Mock

private class MockRepository: ShoppingListRepositoryProtocol {
    func fetchItems() async throws -> [Item] { return [] }
    func addItem(name: String, quantity: Int, note: String?) async throws {}
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws {}
    func deleteItem(_ item: Item) async throws {}
    func toggleBoughtStatus(for item: Item) async throws {}
} 
