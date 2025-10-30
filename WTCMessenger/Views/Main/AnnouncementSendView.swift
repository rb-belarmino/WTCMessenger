import SwiftUI

struct AnnouncementSendView: View {
	@State private var title = ""
	@State private var message = ""
	@State private var selectedSegment = "Todos"
	@State private var segments = ["Todos", "Clientes VIP", "Novos Clientes"]
	@State private var isSent = false
	
	@AppStorage("lastAnnouncementTitle") private var lastAnnouncementTitle: String = ""
	@AppStorage("lastAnnouncementMessage") private var lastAnnouncementMessage: String = ""

	var body: some View {
		VStack(spacing: 16) {
			TextField("Título", text: $title)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			TextField("Mensagem", text: $message)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			Picker("Segmento", selection: $selectedSegment) {
				ForEach(segments, id: \.self) { segment in
					Text(segment)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			Button("Enviar") {
				sendAnnouncement()
			}
			.disabled(title.isEmpty || message.isEmpty)
			if isSent {
				Text("Comunicado enviado!")
					.foregroundColor(.green)
			}
			Spacer()
		}
		.padding()
		.navigationTitle("Novo Comunicado")
	}

	private func sendAnnouncement() {
		lastAnnouncementTitle = title
		lastAnnouncementMessage = message
		isSent = true
	}
}
