import SwiftUI

struct Conversation: Identifiable, Hashable {
	let id = UUID()
	let customerId: String?
	let title: String
	let isGroup: Bool
	let messages: [String]
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func == (lhs: Conversation, rhs: Conversation) -> Bool {
		return lhs.id == rhs.id
	}
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
	@State private var newCustomerEmail = ""
	@State private var newCustomerPhone = ""
	
	@AppStorage("lastAnnouncementTitle") private var lastAnnouncementTitle: String = ""
	@AppStorage("lastAnnouncementMessage") private var lastAnnouncementMessage: String = ""
	@State private var showAnnouncementAlert = false
	
	@State private var conversations: [Conversation] = []
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
					.task {
						await fetchRealConversations()
					}
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
						VStack (spacing: 16){
							Text("Criar Nova Conversa")
								.font(.wtcTitle)
								.foregroundColor(.orange)
								.padding(.bottom, 8)
							
							VStack(alignment: .leading, spacing: 6) {
								Text("Nome do Cliente")
									.font(.wtcCaption)
									.foregroundColor(.gray)
								TextField("Nome completo", text: $recipient)
									.textFieldStyle(RoundedBorderTextFieldStyle())
									.font(.wtcBody)
							}
							
							VStack(alignment: .leading, spacing: 6) {
								Text("E-mail")
									.font(.wtcCaption)
									.foregroundColor(.gray)
								TextField("exemplo@email.com", text: $newCustomerEmail)
									.textFieldStyle(RoundedBorderTextFieldStyle())
									.font(.wtcBody)
									.autocapitalization(.none)
									.keyboardType(.emailAddress)
							}
							
							VStack(alignment: .leading, spacing: 6) {
								Text("Telefone")
									.font(.wtcCaption)
									.foregroundColor(.gray)
								TextField("(11) 99999-9999", text: $newCustomerPhone)
									.textFieldStyle(RoundedBorderTextFieldStyle())
									.font(.wtcBody)
									.keyboardType(.phonePad)
							}
							
							VStack(alignment: .leading, spacing: 6) {
								Text("Mensagem Inicial")
									.font(.wtcCaption)
									.foregroundColor(.gray)
								TextField("Digite a mensagem...", text: $messageText)
									.textFieldStyle(RoundedBorderTextFieldStyle())
									.font(.wtcBody)
							}
							.padding(.bottom, 8)
							
							Button("Enviar e Cadastrar") {
								let name = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
								let email = newCustomerEmail.trimmingCharacters(in: .whitespacesAndNewlines)
								let phone = newCustomerPhone.trimmingCharacters(in: .whitespacesAndNewlines)
								let msg = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
								
								guard !name.isEmpty && !email.isEmpty && !phone.isEmpty && !msg.isEmpty else { return }
								
								Task {
									do {
										// 1. Cria o cliente no MongoDB via backend
										let customer = try await NetworkManager.shared.createCustomer(name: name, email: email, phone: phone)
										
										// 2. Envia a mensagem inicial via REST/Kafka
										try await NetworkManager.shared.sendMessage(recipientId: customer.id, content: msg)
										
										DispatchQueue.main.async {
											// 3. Adiciona a conversa na lista local
											let newConversation = Conversation(customerId: customer.id, title: customer.name, isGroup: false, messages: [msg])
											conversations.append(newConversation)
											
											// Limpa os campos
											recipient = ""
											newCustomerEmail = ""
											newCustomerPhone = ""
											messageText = ""
											showSendMessageSheet = false
										}
									} catch {
										print("❌ Erro ao criar cliente e enviar mensagem: \(error.localizedDescription)")
									}
								}
							}
							.font(.wtcHeadline)
							.foregroundColor(.white)
							.padding()
							.frame(maxWidth: .infinity)
							.background(recipient.isEmpty || newCustomerEmail.isEmpty || newCustomerPhone.isEmpty || messageText.isEmpty ? Color.gray : Color.orange)
							.cornerRadius(8)
							.disabled(recipient.isEmpty || newCustomerEmail.isEmpty || newCustomerPhone.isEmpty || messageText.isEmpty)
							
							Button("Cancelar", role: .cancel) {
								recipient = ""
								newCustomerEmail = ""
								newCustomerPhone = ""
								messageText = ""
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
	
	private func fetchRealConversations() async {
		do {
			let realCustomers = try await NetworkManager.shared.getCustomers()
			DispatchQueue.main.async {
				self.conversations = realCustomers.map { customer in
					Conversation(customerId: customer.id, title: customer.name, isGroup: false, messages: [])
				}
			}
		} catch {
			print("❌ Erro ao buscar clientes no Feed: \(error.localizedDescription)")
		}
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
	@State private var showCustomerTimeline = false

	var allMessages: [ChatMessage] {
		var combined = localMessages
		
		let filteredWS = webSocketManager.incomingMessages.filter { msg in
			msg.recipientId == conversation.customerId || msg.senderId == conversation.customerId
		}
		
		for wsMsg in filteredWS {
			if !combined.contains(where: { $0.id == wsMsg.id }) {
				combined.append(ChatMessage(
					id: wsMsg.id,
					content: wsMsg.content,
					isCurrentUser: wsMsg.recipientId == conversation.customerId,
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
				
				if let customerId = conversation.customerId {
					Button(action: {
						showCustomerTimeline = true
					}) {
						Image(systemName: "info.circle")
							.font(.title2)
							.foregroundColor(.white.opacity(0.9))
					}
					.sheet(isPresented: $showCustomerTimeline) {
						NavigationStack {
							CustomerTimelineView(customerId: customerId)
						}
					}
				}
				
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
		.task {
			await fetchRealMessages()
			
			// Conecta ao WebSocket do Kafka em tempo real
			WebSocketManager.shared.connect()
		}
		.onDisappear {
			// Desconecta e limpa conexão de forma limpa para evitar memory leaks
			WebSocketManager.shared.disconnect()
		}
	}
	
	private func fetchRealMessages() async {
		guard let customerId = conversation.customerId else { return }
		isLoading = true
		do {
			let timeline = try await NetworkManager.shared.getCustomerTimeline(customerId: customerId)
			DispatchQueue.main.async {
				self.localMessages = timeline.recentMessages.map { msg in
					ChatMessage(
						id: msg.id,
						content: msg.content,
						isCurrentUser: msg.recipientId == customerId,
						timestamp: formatDate(msg.createdAt)
					)
				}.reversed()
				self.isLoading = false
			}
		} catch {
			print("❌ Erro ao buscar mensagens reais: \(error.localizedDescription)")
			isLoading = false
		}
	}
	
	private func formatDate(_ dateString: String) -> String {
		let inputFormatter = ISO8601DateFormatter()
		inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		
		if let date = inputFormatter.date(from: dateString) {
			let outputFormatter = DateFormatter()
			outputFormatter.dateFormat = "HH:mm"
			return outputFormatter.string(from: date)
		}
		
		let simpleFormatter = DateFormatter()
		simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		if let date = simpleFormatter.date(from: dateString) {
			let outputFormatter = DateFormatter()
			outputFormatter.dateFormat = "HH:mm"
			return outputFormatter.string(from: date)
		}
		
		return "Recente"
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
				let targetId = conversation.customerId ?? conversation.title
				try await NetworkManager.shared.sendMessage(recipientId: targetId, content: text)
			} catch {
				print("❌ Erro ao enviar mensagem via REST: \(error.localizedDescription)")
			}
		}
	}
}
