import SwiftUI

struct AlertView: View {
	@State private var showAlert = false

	var body: some View {
		Button("Mostrar Alerta") {
			showAlert = true
		}
		.alert("Título do Alerta", isPresented: $showAlert) {
			Button("OK", role: .cancel) { }
		} message: {
			Text("Mensagem do alerta.")
		}
	}
}
