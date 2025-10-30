import SwiftUI

struct SheetView: View {
	@State private var showSheet = false

	var body: some View {
		Button("Mostrar Sheet") {
			showSheet = true
		}
		.sheet(isPresented: $showSheet) {
			VStack {
				Text("Este é um Sheet!")
				Button("Fechar") {
					showSheet = false
				}
			}
			.padding()
		}
	}
}
