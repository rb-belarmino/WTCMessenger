import SwiftUI

// Extension to allow colors by Hex String
extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0) // Default Color
		}

		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue: Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
}

// WTC´s colors Palletes
extension Color {
	static let wtcPrimaryBlue = Color(hex: "#003366")
	static let wtcHighlightOrange = Color(hex: "#E87722")
	static let wtcSecondaryBlue = Color(hex: "#6C8EAD")
	static let wtcDarkGray = Color(hex: "#1C1C1E")
	static let wtcLightGray = Color(hex: "#F0F0F0")
	static let wtcAlertRed = Color(hex: "#E53935")
	static let wtcSuccessGreen = Color(hex: "#43A047")
}

// Font Styles
extension Font {
	static let wtcTitle = Font.system(size: 24, weight: .bold)
	static let wtcHeadline = Font.system(size: 18, weight: .semibold)
	static let wtcBody = Font.system(size: 16, weight: .regular)
	static let wtcCaption = Font.system(size: 12, weight: .medium)
}

// Modifier to set Navigation Bar background color
struct NavigationBarColorModifier: ViewModifier {
	var backgroundColor: Color
	var titleColor: Color

	init(backgroundColor: Color, titleColor: Color) {
		self.backgroundColor = backgroundColor
		self.titleColor = titleColor
		
		let coloredAppearance = UINavigationBarAppearance()
		coloredAppearance.configureWithOpaqueBackground()
		coloredAppearance.backgroundColor = UIColor(backgroundColor)
		coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(titleColor)]
		coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(titleColor)]
		
		UINavigationBar.appearance().standardAppearance = coloredAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
		UINavigationBar.appearance().compactAppearance = coloredAppearance
	}

	func body(content: Content) -> some View {
		content
	}
}

extension View {
	func navigationBarColor(backgroundColor: Color, titleColor: Color) -> some View {
		self.modifier(NavigationBarColorModifier(backgroundColor: backgroundColor, titleColor: titleColor))
	}
}
