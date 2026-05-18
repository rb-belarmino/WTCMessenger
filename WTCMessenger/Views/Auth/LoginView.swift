import SwiftUI

struct LoginView: View {
	@Binding var isAuthenticated: Bool
	@Binding var userRole: String
	@Binding var showLoginAlert: Bool

	@State private var email = ""
	@State private var password = ""
	@State private var isLoading = false
	@State private var errorMessage: String?

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
						.padding(.bottom, 20)

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
								let user = try await NetworkManager.shared.login(email: email, password: Array(password))
								// Define o papel conforme a role retornada do backend
								self.userRole = user.role == .operatorRole ? "operador" : "client"
								self.isAuthenticated = true
								self.showLoginAlert = true
							} catch {
								self.errorMessage = error.localizedDescription
							}
							isLoading = false
						}
					}) {
						HStack {
							if isLoading {
								ProgressView()
									.padding(.trailing, 8)
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
