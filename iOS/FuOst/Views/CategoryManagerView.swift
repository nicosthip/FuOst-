import SwiftUI

struct CategoryManagerView: View {
    @EnvironmentObject var supabase: SupabaseService
    @Environment(\.dismiss) var dismiss
    
    @State private var newCategoryName = ""
    @State private var selectedIcon = "cart.fill"
    @State private var selectedColor = Color.blue
    @State private var isLoading = false
    
    let icons = ["cart.fill", "fork.knife", "car.fill", "house.fill", "gamecontroller.fill", "cross.case.fill", "bolt.fill", "gift.fill", "airplane", "pawprint.fill"]
    let colors: [Color] = [.blue, .orange, .red, .purple, .green, .pink, .yellow, .teal]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text("Información de la categoría")) {
                        TextField("Nombre (Ej: Mascotas)", text: $newCategoryName)
                    }
                    
                    Section(header: Text("Icono")) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 45))], spacing: 15) {
                            ForEach(icons, id: \.self) { icon in
                                ZStack {
                                    Circle()
                                        .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                }
                                .onTapGesture {
                                    withAnimation { selectedIcon = icon }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Section(header: Text("Color")) {
                        HStack(spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                            .padding(-4)
                                    )
                                    .onTapGesture {
                                        withAnimation { selectedColor = color }
                                    }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Nueva Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task { await saveCategory() }
                    }
                    .disabled(newCategoryName.isEmpty || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView().padding().background(.thickMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
    
    private func saveCategory() async {
        isLoading = true
        // Convertir Color a Hex y hacer la llamada a SupabaseService
        // await supabase.addCategory(...)
        // Por ahora simulamos
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        dismiss()
    }
}
