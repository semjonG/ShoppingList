import SwiftUI

/**
 * Main shopping list view that displays the list of items with search, filtering, and sorting capabilities.
 * 
 * This view is used internally by the package and provides the complete shopping list UI.
 * This is the complete UI that was previously in ContentView.
 */
struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // search and Filter Bar
                VStack(spacing: 12) {
                    // search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search items...", text: Binding(
                            get: { viewModel.searchText },
                            set: { viewModel.searchTextChanged($0) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // filter and Sort controls
                    HStack {
                        // show bought items toggle
                        Toggle("Show Bought", isOn: Binding(
                            get: { viewModel.showBoughtItems },
                            set: { viewModel.showBoughtItemsChanged($0) }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        Spacer()
                        
                        // sort picker
                        Picker("Sort", selection: Binding(
                            get: { viewModel.sortOrder },
                            set: { viewModel.sortOrderChanged($0) }
                        )) {
                            Text("Newest First").tag(SortOrder.createdAtDescending)
                            Text("Oldest First").tag(SortOrder.createdAtAscending)
                            Text("Recently Updated").tag(SortOrder.updatedAtDescending)
                            Text("Least Recently Updated").tag(SortOrder.updatedAtAscending)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .padding(.horizontal)
                
                // content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading items...")
                    Spacer()
                } else if viewModel.filteredItems.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No items found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if viewModel.searchText.isEmpty && !viewModel.showBoughtItems {
                            Button("Add your first item") {
                                viewModel.showingAddItem = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredItems) { item in
                            ShoppingItemRow(
                                item: item,
                                onToggleBought: {
                                    await viewModel.toggleBoughtStatus(for: item)
                                },
                                onEdit: {
                                    viewModel.editingItem = item
                                },
                                onDelete: {
                                    await viewModel.deleteItem(item)
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingAddItem = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddItem) {
            AddEditItemView(viewModel: viewModel)
        }
        .sheet(item: $viewModel.editingItem) { item in
            AddEditItemView(viewModel: viewModel, editingItem: item)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil || viewModel.syncError != nil)) {
            Button("OK") {
                viewModel.clearError()
                viewModel.syncError = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else if let syncError = viewModel.syncError {
                Text("Sync Error: \(syncError)")
            }
        }
    }
} 