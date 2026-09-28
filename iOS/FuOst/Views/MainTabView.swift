import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var supabase: SupabaseService
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
        }
        .tint(.purple) // Color vibrante estilo Mon AI
    }
}
