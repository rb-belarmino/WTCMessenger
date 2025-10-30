import SwiftUI

struct User: Identifiable, Hashable {
	let id = UUID()
	let name: String
	let email: String
}

struct UserSearchView: View {
	@State private var searchText = ""
	@State private var users: [User] = [
		User(name: "Ana Souza", email: "ana@email.com"),
		User(name: "Bruno Lima", email: "bruno@email.com"),
		User(name: "Carlos Silva", email: "carlos@email.com"),
		User(name: "Daniela Costa", email: "daniela@email.com"),
		User(name: "Eduardo Pereira", email: "eduardo@email.com"),
		User(name: "Fernanda Rocha", email: "fernanda@email.com"),
		User(name: "Gabriel Mendes", email: "gabriel@email.com")
	]

	var filteredUsers: [User] {
		if searchText.isEmpty {
			return users
		} else {
			return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
		}
	}

	var body: some View {
		VStack {
			TextField("Buscar usuário...", text: $searchText)
				.padding(10)
				.background(Color.wtcLightGray)
				.cornerRadius(8)
				.font(.wtcBody)
				.padding(.horizontal)
			List(filteredUsers) { user in
				VStack(alignment: .leading) {
					Text(user.name).font(.wtcBody)
					Text(user.email).font(.wtcCaption).foregroundColor(.gray)
				}
			}
		}
		.navigationTitle("Buscar Usuários")
	}
}
