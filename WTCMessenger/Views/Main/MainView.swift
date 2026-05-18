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
				if userRole == "operador" {
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
					
					ProfileView(isAuthenticated: $isAuthenticated, userRole: $userRole)
						.tabItem {
							Label("Perfil", systemImage: "person.circle.fill")
						}
				} else {
					// --- CLIENTE (CUSTOMER) TABS ---
					
					// Tab 1: WTC Club Lounge (VIP Portal)
					WTCClubLoungeView()
						.tabItem {
							Label("WTC Club", systemImage: "crown.fill")
						}
					
					// Tab 2: Atendimento Suporte (Direct Chat)
					NavigationStack {
						ChatView(conversation: Conversation(
							customerId: "customer_id",
							title: "Suporte Concierge WTC",
							isGroup: false,
							messages: []
						))
					}
					.tabItem {
						Label("Atendimento", systemImage: "bubble.left.and.bubble.right.fill")
					}
					
					// Tab 3: Perfil do Cliente
					ClientProfileView(isAuthenticated: $isAuthenticated, userRole: $userRole)
						.tabItem {
							Label("Perfil", systemImage: "person.circle.fill")
						}
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
		guard userRole == "operador" else { return }
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
		guard customerId != "customer_id" else {
			self.localMessages = [
				ChatMessage(id: "welcome", content: "Olá! Como podemos ajudar você hoje no WTC Business Club?", isCurrentUser: false, timestamp: "Agora")
			]
			self.isLoading = false
			return
		}
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
		
		let targetId = conversation.customerId ?? conversation.title
		guard targetId != "customer_id" else {
			// Auto-resposta simulada do Concierge após 1.5s
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				let autoReply = ChatMessage(
					id: UUID().uuidString,
					content: "Olá! Sou o assistente Concierge WTC. Identifiquei que você é um Membro Gold e seu score é de 8.5! Como posso lhe ajudar com os benefícios ou agendamento?",
					isCurrentUser: false,
					timestamp: "Agora"
				)
				self.localMessages.append(autoReply)
			}
			return
		}
		
		Task {
			do {
				try await NetworkManager.shared.sendMessage(recipientId: targetId, content: text)
			} catch {
				print("❌ Erro ao enviar mensagem via REST: \(error.localizedDescription)")
			}
		}
	}
}

// MARK: - Cliente VIP Portal (WTC Club Lounge)
struct WTCClubLoungeView: View {
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				// Header
				VStack(spacing: 6) {
					Text("WTC Club Lounge")
						.font(.wtcTitle)
						.foregroundColor(.wtcPrimaryBlue)
					
					Text("PORTAL EXCLUSIVO DO MEMBRO")
						.font(.wtcCaption)
						.foregroundColor(.wtcHighlightOrange)
						.tracking(1.5)
				}
				.padding(.top)
				
				// Gold Virtual Member Card
				VStack(alignment: .leading, spacing: 20) {
					HStack {
						Image(systemName: "crown.fill")
							.font(.title2)
							.foregroundColor(Color(hex: "#FFD700"))
						Text("WTC BUSINESS CLUB")
							.font(.system(size: 14, weight: .bold))
							.foregroundColor(.white)
							.tracking(1.2)
						Spacer()
						Text("GOLD MEMBER")
							.font(.system(size: 11, weight: .black))
							.foregroundColor(Color(hex: "#FFD700"))
							.padding(.horizontal, 8)
							.padding(.vertical, 4)
							.background(Color.white.opacity(0.12))
							.cornerRadius(6)
					}
					
					Spacer()
						.frame(height: 20)
					
					VStack(alignment: .leading, spacing: 4) {
						Text("Membro Titular")
							.font(.system(size: 10, weight: .medium))
							.foregroundColor(.white.opacity(0.6))
						Text(NetworkManager.shared.currentUser?.name ?? "Membro WTC Club")
							.font(.wtcHeadline)
							.foregroundColor(.white)
					}
					
					HStack {
						VStack(alignment: .leading, spacing: 2) {
							Text("Member ID")
								.font(.system(size: 8, weight: .medium))
								.foregroundColor(.white.opacity(0.6))
							Text("WTC-360-KAFKA")
								.font(.system(size: 11, weight: .bold, design: .monospaced))
								.foregroundColor(.white)
						}
						Spacer()
						VStack(alignment: .trailing, spacing: 2) {
							Text("Status da Conta")
								.font(.system(size: 8, weight: .medium))
								.foregroundColor(.white.opacity(0.6))
							HStack(spacing: 4) {
								Circle()
									.fill(Color.wtcSuccessGreen)
									.frame(width: 6, height: 6)
								Text("Ativa")
									.font(.system(size: 11, weight: .bold))
									.foregroundColor(.wtcSuccessGreen)
							}
						}
					}
				}
				.padding(24)
				.background(
					LinearGradient(
						gradient: Gradient(colors: [Color(hex: "#1A1A1A"), Color(hex: "#333333"), Color(hex: "#0F2027")]),
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				)
				.cornerRadius(20)
				.shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
				.overlay(
					RoundedRectangle(cornerRadius: 20)
						.stroke(Color(hex: "#FFD700").opacity(0.2), lineWidth: 1)
				)
				.padding(.horizontal)
				
				// Fidelidade & Score Card
				VStack(alignment: .leading, spacing: 16) {
					HStack {
						Image(systemName: "bolt.fill")
							.foregroundColor(.wtcHighlightOrange)
						Text("Indicador de Fidelidade CRM")
							.font(.wtcHeadline)
							.foregroundColor(.wtcPrimaryBlue)
						Spacer()
						Text("8.5 / 10.0")
							.font(.wtcHeadline)
							.foregroundColor(.wtcHighlightOrange)
					}
					
					// Custom Progress Bar
					GeometryReader { geometry in
						ZStack(alignment: .leading) {
							Capsule()
								.fill(Color.wtcLightGray)
								.frame(height: 10)
							
							Capsule()
								.fill(LinearGradient(colors: [.wtcHighlightOrange, .orange], startPoint: .leading, endPoint: .trailing))
								.frame(width: geometry.size.width * 0.85, height: 10)
						}
					}
					.frame(height: 10)
					
					Text("Parabéns! Seu score de engajamento é excelente. Você possui acesso prioritário ao concierge e convites especiais do Business Club.")
						.font(.wtcCaption)
						.foregroundColor(.gray)
						.lineSpacing(4)
				}
				.padding()
				.background(Color.white)
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
				.padding(.horizontal)
				
				// Benefícios Disponíveis (Privileges Grid)
				VStack(alignment: .leading, spacing: 16) {
					Text("Privilégios Exclusivos")
						.font(.wtcHeadline)
						.foregroundColor(.wtcPrimaryBlue)
						.padding(.horizontal)
					
					VStack(spacing: 12) {
						PrivilegeRow(title: "Atendimento VIP Concierge", desc: "Suporte operacional executivo 24/7 no chat.", icon: "bubble.left.and.bubble.right.fill", color: .wtcHighlightOrange)
						PrivilegeRow(title: "WTC Networking Club", desc: "Convites garantidos para rodadas de negócios da FIAP.", icon: "person.2.fill", color: .wtcPrimaryBlue)
						PrivilegeRow(title: "Acesso a Salas VIP", desc: "Salas de reunião exclusivas no complexo WTC.", icon: "building.2.fill", color: .wtcSecondaryBlue)
					}
					.padding(.horizontal)
				}
			}
		}
		.background(Color.wtcLightGray.opacity(0.6).edgesIgnoringSafeArea(.all))
	}
}

struct PrivilegeRow: View {
	var title: String
	var desc: String
	var icon: String
	var color: Color
	
	var body: some View {
		HStack(spacing: 16) {
			ZStack {
				Circle()
					.fill(color.opacity(0.12))
					.frame(width: 44, height: 44)
				Image(systemName: icon)
					.font(.title3)
					.foregroundColor(color)
			}
			
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.wtcHeadline)
					.foregroundColor(.wtcDarkGray)
				Text(desc)
					.font(.wtcCaption)
					.foregroundColor(.gray)
			}
			Spacer()
		}
		.padding()
		.background(Color.white)
		.cornerRadius(16)
		.shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
	}
}

// MARK: - Cliente Profile View
struct ClientProfileView: View {
	@Binding var isAuthenticated: Bool
	@Binding var userRole: String
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				// Header
				VStack(spacing: 8) {
					Text("Meu Perfil WTC")
						.font(.wtcTitle)
						.foregroundColor(.wtcPrimaryBlue)
					
					Text("WTC BUSINESS CLUB")
						.font(.wtcCaption)
						.foregroundColor(.wtcSecondaryBlue)
						.tracking(1.5)
				}
				.padding(.top)
				
				// Card de Dados
				VStack(spacing: 16) {
					HStack(spacing: 16) {
						ZStack {
							Circle()
								.fill(LinearGradient(gradient: Gradient(colors: [.wtcHighlightOrange, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
								.frame(width: 64, height: 64)
							
							Text(getInitials())
								.font(.wtcHeadline)
								.foregroundColor(.white)
						}
						
						VStack(alignment: .leading, spacing: 4) {
							Text(NetworkManager.shared.currentUser?.name ?? "Cliente WTC")
								.font(.wtcHeadline)
								.foregroundColor(.wtcDarkGray)
							
							Text(NetworkManager.shared.currentUser?.email ?? "cliente@wtc.com")
								.font(.wtcCaption)
								.foregroundColor(.gray)
						}
						Spacer()
					}
					
					Divider()
					
					HStack {
						VStack(alignment: .leading, spacing: 4) {
							Text("Categoria de Membro")
								.font(.wtcCaption)
								.foregroundColor(.gray)
							Text("GOLD MEMBER")
								.font(.wtcBody)
								.fontWeight(.semibold)
								.foregroundColor(.wtcHighlightOrange)
						}
						Spacer()
						VStack(alignment: .trailing, spacing: 4) {
							Text("Conta CRM")
								.font(.wtcCaption)
								.foregroundColor(.gray)
							Text("Ativo")
								.font(.wtcBody)
								.foregroundColor(.wtcSuccessGreen)
								.fontWeight(.bold)
						}
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
				.padding(.horizontal)
				
				// Botão Sair com estilo Premium
				Button(action: {
					logout()
				}) {
					HStack {
						Image(systemName: "power")
							.font(.headline)
						Text("Encerrar Sessão")
							.font(.wtcHeadline)
					}
					.foregroundColor(.white)
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.wtcAlertRed)
					.cornerRadius(12)
					.shadow(color: Color.wtcAlertRed.opacity(0.3), radius: 5, x: 0, y: 3)
				}
				.padding(.horizontal)
				.padding(.top, 8)
			}
		}
		.background(Color.wtcLightGray.opacity(0.6).edgesIgnoringSafeArea(.all))
	}
	
	private func getInitials() -> String {
		let name = NetworkManager.shared.currentUser?.name ?? "Cliente WTC"
		let words = name.components(separatedBy: " ")
		if words.count >= 2 {
			return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
		}
		return String(name.prefix(2)).uppercased()
	}
	
	private func logout() {
		NetworkManager.shared.accessToken = nil
		NetworkManager.shared.refreshToken = nil
		NetworkManager.shared.currentUser = nil
		isAuthenticated = false
		userRole = ""
	}
}
