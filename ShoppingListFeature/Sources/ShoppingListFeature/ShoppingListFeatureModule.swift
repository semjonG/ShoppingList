import SwiftUI
import SwiftData

/**
 * Main module for the ShoppingListFeature package.
 * 
 * Super simple integration for super-apps - just call createView()!
 */
@MainActor
public class ShoppingListFeatureModule {
    
    /**
     * Creates a shopping list view - super simple integration!
     * 
     * - Parameter modelContext: The SwiftData model context
     * - Returns: A complete shopping list view
     */
    public static func createView(modelContext: ModelContext) -> some View {
        createView(modelContext: modelContext, enableSync: false)
    }
    
    /**
     * Creates a shopping list view with optional sync.
     * 
     * - Parameters:
     *   - modelContext: The SwiftData model context
     *   - enableSync: Whether to enable sync (default: false)
     * - Returns: A complete shopping list view
     */
    public static func createView(
        modelContext: ModelContext,
        enableSync: Bool = false
    ) -> some View {
        ShoppingListViewWithSetup(modelContext: modelContext, enableSync: enableSync)
    }
}

// MARK: - Shopping List View with Setup

/**
 * Shopping list view that handles its own setup.
 */
private struct ShoppingListViewWithSetup: View {
    @State private var viewModel: ShoppingListViewModel?
    private let modelContext: ModelContext
    private let enableSync: Bool
    
    init(modelContext: ModelContext, enableSync: Bool = false) {
        self.modelContext = modelContext
        self.enableSync = enableSync
    }
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                ShoppingListView(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        createViewModel()
                    }
            }
        }
    }
    
    private func createViewModel() {
        // Create repository
        let repository = ShoppingListRepository(modelContext: modelContext, syncService: nil)
        
        // Create sync service if enabled
        let syncService: SyncServiceProtocol?
        if enableSync {
            let networkService = MockNetworkService()
            let backgroundTaskService = BackgroundTaskService()
            
            let service = SyncService(
                networkService: networkService,
                repository: repository,
                backgroundTaskService: backgroundTaskService
            )
            
            repository.setSyncService(service)
            syncService = service
        } else {
            syncService = nil
        }
        
        // Create view model on main actor
        Task { @MainActor in
            viewModel = ShoppingListViewModel(repository: repository, syncService: syncService)
        }
    }
} 