import SwiftUI

struct DemoPopupView: View {
	@State private var showAlert = false
	@State private var showSheet = false

	var body: some View {
		VStack(spacing: 24) {
			// Button to show Alert
			Button("Mostrar Alerta") {
				showAlert = true
			}
			.alert("Título do Alerta", isPresented: $showAlert) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("Mensagem do alerta.")
			}

			// Button to show Sheet
			Button("Mostrar Sheet") {
				showSheet = true
			}
			.sheet(isPresented: $showSheet) {
				VStack {
					Text("Este é um Sheet!")
						.font(.headline)
					Button("Fechar") {
						showSheet = false
					}
				}
				.padding()
			}
		}
		.padding()
	}
}
