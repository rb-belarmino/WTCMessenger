import SwiftUI

struct ProfileView: View {
	@Binding var isAuthenticated: Bool
	@Binding var userRole: String

	var body: some View {
		VStack(spacing: 24) {
			Text("Perfil do Usuário")
				.font(.title)
				.padding()

			Text("Função: \(userRole)")
				.font(.subheadline)

			Button(action: {
				logout()
			}) {
				Text("Sair")
					.foregroundColor(.white)
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.red)
					.cornerRadius(8)
			}
			.padding(.horizontal)
		}
	}

	private func logout() {
		NetworkManager.shared.accessToken = nil
		NetworkManager.shared.refreshToken = nil
		NetworkManager.shared.currentUser = nil
		isAuthenticated = false
		userRole = ""
	}
}

#Preview {
	ProfileView(isAuthenticated: .constant(true), userRole: .constant("operador"))
}
