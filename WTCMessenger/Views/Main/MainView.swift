import SwiftUI

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
				
				// Feed: Messages
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
				
				// CRM: Notes with detail
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
				
				//Profile View
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
		NetworkManager.shared.accessToken = nil
		NetworkManager.shared.refreshToken = nil
		NetworkManager.shared.currentUser = nil
		isAuthenticated = false
		userRole = ""
	}
}

struct ChatMessage: Identifiable, Equatable {
	let id: String
	let content: String
	let isCurrentUser: Bool
	let timestamp: String
}

struct ChatView: View {
	let conversation: Conversation
	@Environment(\.dismiss) var dismiss
	
	@ObservedObject var webSocketManager = WebSocketManager.shared
	
	@State private var messageText = ""
	@State private var isLoading = false
	@State private var localMessages: [ChatMessage] = []

	var allMessages: [ChatMessage] {
		var combined = localMessages
		
		// Filter and append WebSocket messages that belong to this chat
		let filteredWS = webSocketManager.incomingMessages.filter { msg in
			msg.recipientId == conversation.title || true // Fallback to show all in this direct demo chat
		}
		
		for wsMsg in filteredWS {
			if !combined.contains(where: { $0.id == wsMsg.id }) {
				combined.append(ChatMessage(
					id: wsMsg.id,
					content: wsMsg.content,
					isCurrentUser: wsMsg.recipientId == conversation.title,
					timestamp: "Agora"
				))
			}
		}
		
		return combined
	}

	var body: some View {
		VStack(spacing: 0) {
			// Header do Chat
			HStack(spacing: 12) {
				ZStack {
					Circle()
						.fill(Color.white.opacity(0.2))
						.frame(width: 40, height: 40)
					Text(String(conversation.title.prefix(2)).uppercased())
						.font(.wtcHeadline)
						.foregroundColor(.white)
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(conversation.title)
						.font(.wtcHeadline)
						.foregroundColor(.white)
					HStack(spacing: 4) {
						Circle()
							.fill(Color.wtcSuccessGreen)
							.frame(width: 8, height: 8)
						Text("Conectado (Kafka)")
							.font(.wtcCaption)
							.foregroundColor(.white.opacity(0.8))
					}
				}
				
				Spacer()
				
				Button(action: {
					dismiss()
				}) {
					Image(systemName: "xmark.circle.fill")
						.font(.title2)
						.foregroundColor(.white.opacity(0.8))
				}
			}
			.padding()
			.background(Color.wtcPrimaryBlue)
			
			// Feed de Mensagens com Rolar Automático
			ScrollViewReader { proxy in
				ScrollView {
					VStack(spacing: 12) {
						ForEach(allMessages) { msg in
							HStack {
								if msg.isCurrentUser {
									Spacer()
									Text(msg.content)
										.font(.wtcBody)
										.foregroundColor(.white)
										.padding(.horizontal, 16)
										.padding(.vertical, 10)
										.background(Color.wtcHighlightOrange)
										.cornerRadius(16)
								} else {
									Text(msg.content)
										.font(.wtcBody)
										.foregroundColor(.primary)
										.padding(.horizontal, 16)
										.padding(.vertical, 10)
										.background(Color.wtcLightGray)
										.cornerRadius(16)
									Spacer()
								}
							}
							.id(msg.id)
						}
					}
					.padding()
				}
				.onChange(of: allMessages.count) { oldValue, newValue in
					if let lastMsg = allMessages.last {
						withAnimation {
							proxy.scrollTo(lastMsg.id, anchor: .bottom)
						}
					}
				}
				.onAppear {
					if let lastMsg = allMessages.last {
						proxy.scrollTo(lastMsg.id, anchor: .bottom)
					}
				}
			}
			
			// Barra de Input
			HStack(spacing: 12) {
				TextField("Digite sua mensagem...", text: $messageText)
					.padding(12)
					.background(Color.wtcLightGray)
					.cornerRadius(20)
					.font(.wtcBody)
					.onSubmit {
						sendMessage()
					}
				
				Button(action: sendMessage) {
					Image(systemName: "paperplane.fill")
						.font(.headline)
						.foregroundColor(.white)
						.frame(width: 44, height: 44)
						.background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.wtcHighlightOrange)
						.clipShape(Circle())
						.shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
				}
				.disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
			.padding()
			.background(Color.white)
			.shadow(color: .black.opacity(0.05), radius: 5, y: -2)
		}
		.onAppear {
			// Preencher mensagens mock iniciais
			var initialMsgs: [ChatMessage] = []
			for (index, msg) in conversation.messages.enumerated() {
				initialMsgs.append(ChatMessage(
					id: "mock-\(index)",
					content: msg,
					isCurrentUser: index % 2 == 1,
					timestamp: "Recente"
				))
			}
			self.localMessages = initialMsgs
			
			// Conecta ao WebSocket do Kafka em tempo real
			WebSocketManager.shared.connect()
		}
		.onDisappear {
			// Desconecta e limpa conexão de forma limpa para evitar memory leaks
			WebSocketManager.shared.disconnect()
		}
	}
	
	private func sendMessage() {
		let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !text.isEmpty else { return }
		
		messageText = ""
		
		// Update otimista imediato no Feed
		let tempId = UUID().uuidString
		let newMsg = ChatMessage(id: tempId, content: text, isCurrentUser: true, timestamp: "Agora")
		localMessages.append(newMsg)
		
		Task {
			do {
				try await NetworkManager.shared.sendMessage(recipientId: conversation.title, content: text)
			} catch {
				print("❌ Erro ao enviar mensagem via REST: \(error.localizedDescription)")
			}
		}
	}
}
