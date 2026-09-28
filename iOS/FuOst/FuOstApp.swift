import SwiftUI

@main
struct FuOstApp: App {
    // Inicializamos el servicio de Supabase
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some Scene {
        WindowGroup {
            if supabaseService.currentUser == nil {
                LoginView()
                    .environmentObject(supabaseService)
            } else {
                MainTabView()
                    .environmentObject(supabaseService)
            }
        }
    }
}
