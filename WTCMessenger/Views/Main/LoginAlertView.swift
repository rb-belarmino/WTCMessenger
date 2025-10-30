import SwiftUI

struct LoginAlertView: View {
	@Binding var show: Bool
	var userRole: String

	var body: some View {
		EmptyView()
			.alert("Nova mensagem", isPresented: $show) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("Você tem uma nova mensagem!")
			}
	}
}
