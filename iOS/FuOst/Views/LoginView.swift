import SwiftUI

struct LoginView: View {
    @EnvironmentObject var supabase: SupabaseService
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Logo o Título
                    VStack(spacing: 10) {
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.bottom, 10)
                        
                        Text("FuOst")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                        Text("Tu gestor financiero personal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 30)
                    
                    // Formulario
                    VStack(spacing: 15) {
                        TextField("Correo Electrónico", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        
                        SecureField("Contraseña", text: $password)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Botón Principal
                    Button(action: {
                        Task { await handleAuth() }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(isRegistering ? "Crear Cuenta" : "Iniciar Sesión")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    // Cambiar Modo
                    Button(action: {
                        withAnimation {
                            isRegistering.toggle()
                            errorMessage = nil
                        }
                    }) {
                        Text(isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    // MARK: - Lógica de Autenticación
    private func handleAuth() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if isRegistering {
                // Registrar usuario (la función signInAuth/signUp dependerá de cómo actualices SupabaseService)
                // Por ahora usamos la de login para el esqueleto
                try await supabase.signIn(email: email, password: password)
            } else {
                try await supabase.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
