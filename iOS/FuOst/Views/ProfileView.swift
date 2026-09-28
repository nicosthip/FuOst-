import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var supabase: SupabaseService
    var body: some View {
        NavigationStack {
            Text("Perfil")
                .navigationTitle("Perfil")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var supabase: SupabaseService
    var body: some View {
        NavigationStack {
            List {
                Button("Cerrar Sesión") {
                    Task {
                        try? await supabase.signOut()
                    }
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Ajustes")
        }
    }
}
