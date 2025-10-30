import SwiftUI
import Supabase

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
		Task {
			do {
				try await SupabaseManager.shared.client.auth.signOut()
				isAuthenticated = false
				userRole = ""
			} catch {
				print("Erro ao fazer logout: \(error.localizedDescription)")
			}
		}
	}
}

#Preview {
	ProfileView(isAuthenticated: .constant(true), userRole: .constant("operador"))
}
