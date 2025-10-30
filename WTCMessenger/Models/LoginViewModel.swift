import Foundation
import Supabase
import Combine

@MainActor
class LoginViewModel: ObservableObject {
	@Published var email = ""
	@Published var password = ""
	@Published var isLoading = false
	@Published var errorMessage: String?
	
	func login() async -> Bool {
		isLoading = true
		defer { isLoading = false }
		do {
			_ = try await SupabaseManager.shared.client.auth.signIn(
				email: email,
				password: password
			)
			errorMessage = nil
			return true
		} catch {
			errorMessage = "Usuário ou senha inválidos."
			return false
		}
	}
}
