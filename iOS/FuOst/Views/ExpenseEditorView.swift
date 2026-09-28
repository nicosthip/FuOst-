import SwiftUI

struct ExpenseEditorView: View {
    @EnvironmentObject var supabase: SupabaseService
    @Environment(\.dismiss) var dismiss
    
    // Si viene un expense, estamos editando. Si es nil, es uno nuevo.
    var expenseToEdit: Expense?
    
    @State private var amount: Double = 0.0
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                Form {
                    Section {
                        HStack {
                            Text("$")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            TextField("0.00", value: $amount, format: .number)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .keyboardType(.decimalPad)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    Section {
                        TextField("¿En qué gastaste? (Ej: Uber)", text: $note)
                        DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section {
                        // Aquí iría un picker de categoría
                        NavigationLink(destination: Text("Seleccionar Categoría")) {
                            HStack {
                                Text("Categoría")
                                Spacer()
                                Text("Comida").foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if expenseToEdit != nil {
                        Section {
                            Button(role: .destructive, action: {
                                Task { await deleteExpense() }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Eliminar Gasto")
                                        .bold()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(expenseToEdit == nil ? "Nuevo Gasto" : "Editar Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task { await saveExpense() }
                    }
                    .disabled(amount <= 0 || isLoading)
                }
            }
        }
        .onAppear {
            if let exp = expenseToEdit {
                amount = NSDecimalNumber(decimal: exp.amount).doubleValue
                note = exp.note ?? ""
                date = exp.date
            }
        }
    }
    
    private func saveExpense() async {
        isLoading = true
        // await supabase.updateExpense(...)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        dismiss()
    }
    
    private func deleteExpense() async {
        isLoading = true
        // await supabase.deleteExpense(...)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        dismiss()
    }
}
