import SwiftUI
import Supabase

struct LoginView: View {
	@Binding var isAuthenticated: Bool
	@Binding var userRole: String
	@Binding var showLoginAlert: Bool

	@State private var email = ""
	@State private var password = ""
	@State private var isLoading = false
	@State private var errorMessage: String?

	enum RolePicker {
		case client, operador
	}
	@State private var roleSelection: RolePicker = .client

	var body: some View {
		NavigationStack {
			ZStack {
				LinearGradient(
					colors: [Color.wtcPrimaryBlue.opacity(0.8), .wtcDarkGray],
					startPoint: .top,
					endPoint: .bottom
				)
				.edgesIgnoringSafeArea(.all)

				VStack(spacing: 20) {
					Spacer()
					Image(systemName: "building.2.crop.circle.fill")
						.font(.system(size: 80))
						.foregroundColor(.wtcHighlightOrange)
						.padding(.bottom, 20)

					Text("WTC Business Club")
						.font(.wtcTitle)
						.foregroundColor(.white)

					Picker("Tipo de Usuário", selection: $roleSelection) {
						Text("Cliente").tag(RolePicker.client)
						Text("Operador").tag(RolePicker.operador)
					}
					.pickerStyle(.segmented)
					.background(Color.wtcSecondaryBlue.opacity(0.5))
					.cornerRadius(8)
					.padding(.horizontal, 40)

					TextField("Email", text: $email)
						.padding()
						.background(Color.white.opacity(0.9))
						.cornerRadius(10)
						.keyboardType(.emailAddress)
						.autocapitalization(.none)

					SecureField("Senha", text: $password)
						.padding()
						.background(Color.white.opacity(0.9))
						.cornerRadius(10)

					if let errorMessage = errorMessage {
						Text(errorMessage)
							.foregroundColor(.red)
							.font(.caption)
					}

					Button(action: {
						isLoading = true
						errorMessage = nil

						Task {
							do {
								try await SupabaseManager.shared.client.auth.signOut()
								// Define o papel conforme o picker
								self.userRole = roleSelection == .operador ? "operador" : "client"
								self.isAuthenticated = true
								self.showLoginAlert = true
							} catch {
								self.errorMessage = "Erro ao autenticar"
							}
							isLoading = false
						}
					}) {
						HStack {
							if isLoading {
								ProgressView()
							}
							Text("Entrar")
								.font(.wtcHeadline)
								.foregroundColor(.white)
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.wtcHighlightOrange)
						.cornerRadius(10)
						.shadow(color: .black.opacity(0.2), radius: 5, y: 3)
					}

					Spacer()
					Spacer()
				}
				.padding()
			}
			.navigationTitle("Login")
			.navigationBarHidden(true)
		}
	}
}
