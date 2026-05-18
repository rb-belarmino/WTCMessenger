import Foundation
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
			_ = try await NetworkManager.shared.login(
				email: email,
				password: Array(password)
			)
			errorMessage = nil
			return true
		} catch {
			errorMessage = error.localizedDescription
			return false
		}
	}
}
