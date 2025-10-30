import SwiftUI

struct NoteDetailView: View {
	let note: Note

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Anotação")
				.font(.wtcTitle)
				.foregroundColor(.wtcPrimaryBlue)
			Text(note.text)
				.font(.wtcBody)
			Text("Cliente: \(note.client)")
				.font(.wtcCaption)
				.foregroundColor(.gray)
			Spacer()
		}
		.padding()
		.navigationTitle("Detalhe")
	}
}
