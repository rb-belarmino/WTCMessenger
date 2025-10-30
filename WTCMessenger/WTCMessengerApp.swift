
import SwiftUI

@main
struct WTCMessengerApp: App {
	
	// Variables to control navigation
	@State private var isAuthenticated = false
	@State private var userRole = "client"
	@State private var showLoginAlert = false

	var body: some Scene {
		WindowGroup {
			if isAuthenticated {
				MainView(isAuthenticated: $isAuthenticated, userRole: $userRole, showLoginAlert: $showLoginAlert)
					
			} else {
				LoginView(isAuthenticated: $isAuthenticated, userRole: $userRole, showLoginAlert: $showLoginAlert)
					
			}
			}
		}
	}
