import SwiftUI
import Supabase

struct Conversation: Identifiable {
	let id = UUID()
	let title: String
	let isGroup: Bool
	let messages: [String]
}

struct Note: Identifiable, Hashable {
	let id = UUID()
	var text: String
	var client: String
}

struct MainView: View {
	
	@Binding var isAuthenticated: Bool
	@Binding var userRole: String
	@Binding var showLoginAlert: Bool
	
	@State private var showLogoutAlert = false
	@State private var showSendMessageSheet = false
	@State private var recipient = ""
	@State private var messageText = ""
	
	@AppStorage("lastAnnouncementTitle") private var lastAnnouncementTitle: String = ""
	@AppStorage("lastAnnouncementMessage") private var lastAnnouncementMessage: String = ""
	@State private var showAnnouncementAlert = false
	
	@State private var conversations: [Conversation] = [
		Conversation(title: "João Silva", isGroup: false, messages: ["Oi!", "Tudo bem?"]),
		Conversation(title: "Equipe Vendas", isGroup: true, messages: ["Reunião às 10h", "Ok!"])
	]
	@State private var selectedConversation: Conversation?
	
	@State private var notes: [Note] = [
		Note(text: "Primeira anotação", client: "Cliente A"),
		Note(text: "Segunda anotação", client: "Cliente B")
	]
	@State private var newNote: String = ""
	@State private var newClient: String = ""
	
	@State private var showDemoPopup = false
	
	var body: some View {
		NavigationView {
			TabView {
					// Feed: Conversas
				NavigationStack {
					List(conversations) { conversation in
						Button {
							selectedConversation = conversation
						} label: {
							HStack {
								Image(systemName: conversation.isGroup ? "person.3.fill" : "person.fill")
								Text(conversation.title)
							}
						}
					}
					.navigationTitle("Conversas")
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button(action: {
								showSendMessageSheet = true
							}) {
								Image(systemName: "plus")
									.font(.title2)
									.foregroundColor(.white)
									.padding(8)
									.background(Color.orange)
									.clipShape(Circle())
									.shadow(radius: 2)
							}
						}
					}
					.sheet(isPresented: $showSendMessageSheet) {
						VStack (spacing: 20){
							Text("Enviar Mensagem")
								.font(.wtcTitle)
								.foregroundColor(.orange)
							TextField("Destinatário", text: $recipient)
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.font(.wtcBody)
							TextField("Mensagem", text: $messageText)
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.font(.wtcBody)
							Button("Enviar") {
								let newConversation = Conversation(title: recipient, isGroup: false, messages: [messageText])
								conversations.append(newConversation)
								print("Mensagem para \(recipient): \(messageText)")
								recipient = ""
								messageText = ""
								showSendMessageSheet = false
							}
							.font(.wtcBody)
							.foregroundColor(.white)
							.padding()
							.background(Color.orange)
							.cornerRadius(8)
							.disabled(recipient.isEmpty || messageText.isEmpty)
							
							Button("Cancelar", role: .cancel) {
								showSendMessageSheet = false
							}
							.font(.wtcBody)
							.foregroundColor(.orange)
						}
						.padding()
						.background(Color.wtcLightGray)
						.cornerRadius(16)
						.padding()
					}
					.sheet(item: $selectedConversation) { conv in
						ChatView(conversation: conv)
					}
				}
				.tabItem {
					Label("Feed", systemImage: "message.fill")
				}
				
					// CRM: Notas com detalhe
				if userRole == "operador" {
					DemoPopupView()
						.tabItem {
							Label("Popups", systemImage: "rectangle.stack.fill.badge.plus")
						}
					NavigationStack {
						VStack {
							NavigationLink(destination: AnnouncementSendView()) {
								Text("Enviar Comunicado")
								Image(systemName: "megaphone.fill")
									.font(.wtcBody)
									.foregroundColor(.wtcPrimaryBlue)
							}
							.padding(8)
							.background(Color.wtcLightGray)
							.cornerRadius(8)
							NavigationStack{
								NavigationLink(destination: UserSearchView()) {
									HStack {
										Text("Buscar Usuários")
										Image(systemName: "magnifyingglass")
											.font(.wtcBody)
											.foregroundColor(.wtcPrimaryBlue)
									}
									.padding(8)
									.background(Color.wtcLightGray)
									.cornerRadius(8)
								}
							}
							.padding(.horizontal)
							
							Text("Anotações CRM")
								.font(.wtcTitle)
								.foregroundColor(.wtcPrimaryBlue)
								.padding(.top, 16)
								.padding(.bottom, 8)
							List {
								ForEach(notes) { note in
									NavigationLink(destination: NoteDetailView(note: note)) {
										VStack(alignment: .leading) {
											Text(note.text)
											Text("Cliente: \(note.client)")
												.font(.caption)
												.foregroundColor(.gray)
										}
									}
								}
								.onDelete(perform: deleteNote)
							}
							HStack {
								TextField("Nova anotação", text: $newNote)
									.textFieldStyle(RoundedBorderTextFieldStyle())
								TextField("Cliente", text: $newClient)
									.textFieldStyle(RoundedBorderTextFieldStyle())
								Button(action: addNote) {
									Image(systemName: "plus.circle.fill")
										.font(.title2)
								}
								.disabled(newNote.isEmpty || newClient.isEmpty)
							}
							.padding()
						}
					}
					.tabItem {
						Label("CRM", systemImage: "person.2.fill")
					}
				}
				
					// Perfil
				ProfileView(isAuthenticated: $isAuthenticated, userRole: $userRole)
					.tabItem {
						Label("Perfil", systemImage: "person.circle.fill")
					}
			}
			.accentColor(.orange)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Sair") {
						showLogoutAlert = true
					}
					.foregroundColor(.red)
				}
			}
			.alert("Deseja realmente sair?", isPresented: $showLogoutAlert) {
				Button("Cancelar", role: .cancel) {}
				Button("Sair", role: .destructive) {
					logout()
				}
			}
			.alert("Mensagem nova!", isPresented: $showLoginAlert) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("Você tem uma nova mensagem!")
			}
			
			LoginAlertView(show: $showLoginAlert, userRole: userRole)
			
		}
	}
	
	private func addNote() {
		notes.append(Note(text: newNote, client: newClient))
		newNote = ""
		newClient = ""
	}

	private func deleteNote(at offsets: IndexSet) {
		notes.remove(atOffsets: offsets)
	}

	private func logout() {
		Task {
			do {
				try await SupabaseManager.shared.client.auth.signOut()
				isAuthenticated = false
				userRole = ""
			} catch {
				print("Erro ao fazer logout: \(error.localizedDescription)")
			}
		}
	}
}

struct ChatView: View {
	let conversation: Conversation

	var body: some View {
		VStack {
			Text(conversation.title)
				.font(.headline)
			List(conversation.messages, id: \.self) { msg in
				Text(msg)
			}
			Spacer()
		}
		.padding()
	}
}
