import SwiftUI

struct CustomPopupView: View {
	@State private var showPopup = false

	var body: some View {
		ZStack {
			Button("Mostrar Popup Customizado") {
				showPopup = true
			}

			if showPopup {
				VStack(spacing: 20) {
					Text("Popup Customizado")
						.font(.headline)
					Button("Fechar") {
						showPopup = false
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(12)
				.shadow(radius: 10)
				.frame(maxWidth: 250)
				.zIndex(1)
			}
		}
		.background(Color.black.opacity(showPopup ? 0.4 : 0))
		.animation(.easeInOut, value: showPopup)
	}
}
