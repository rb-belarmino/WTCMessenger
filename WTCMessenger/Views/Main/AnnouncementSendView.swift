import SwiftUI

struct AnnouncementSendView: View {
	@Environment(\.dismiss) var dismiss
	
	// Form fields
	@State private var title = ""
	@State private var message = ""
	@State private var bannerUrl = "https://via.placeholder.com/600x300"
	@State private var selectedSegment = "Todos"
	@State private var segments = ["Todos", "Clientes VIP", "Novos Clientes"]
	
	// AI Copilot state
	@State private var briefing = ""
	@State private var isAIGenerating = false
	@State private var suggestedActions: [CampaignAction] = []
	@State private var suggestedActionUrls: [String: String] = [:]
	
	// Action/Feedback state
	@State private var isSending = false
	@State private var isSent = false
	@State private var errorMessage = ""
	
	@AppStorage("lastAnnouncementTitle") private var lastAnnouncementTitle: String = ""
	@AppStorage("lastAnnouncementMessage") private var lastAnnouncementMessage: String = ""

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				// Seção 1: Copiloto WTC
				VStack(alignment: .leading, spacing: 14) {
					HStack(spacing: 8) {
						Image(systemName: "sparkles")
							.font(.title3)
							.foregroundColor(.wtcHighlightOrange)
						Text("Copiloto de IA WTC")
							.font(.wtcHeadline)
							.foregroundColor(.wtcPrimaryBlue)
						Spacer()
					}
					
					Text("Digite abaixo um briefing livre para a Inteligência Artificial do Gemini gerar o rascunho completo da sua campanha e ações integradas no aplicativo.")
						.font(.wtcCaption)
						.foregroundColor(.gray)
					
					TextEditor(text: $briefing)
						.frame(height: 80)
						.padding(8)
						.background(Color.wtcLightGray)
						.cornerRadius(8)
						.overlay(
							RoundedRectangle(cornerRadius: 8)
								.stroke(Color.gray.opacity(0.2), lineWidth: 1)
						)
						.font(.wtcBody)
					
					Button(action: generateWithAI) {
						HStack(spacing: 8) {
							if isAIGenerating {
								ProgressView()
									.progressViewStyle(CircularProgressViewStyle(tint: .white))
							} else {
								Image(systemName: "wand.and.stars")
									.font(.headline)
							}
							Text(isAIGenerating ? "Gerando Campanha..." : "✨ Gerar com IA")
								.font(.wtcHeadline)
						}
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.frame(height: 44)
						.background(briefing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAIGenerating ? Color.gray : Color.wtcHighlightOrange)
						.cornerRadius(10)
						.shadow(color: .black.opacity(0.05), radius: 5, y: 2)
					}
					.disabled(briefing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAIGenerating)
					
					if !errorMessage.isEmpty && title.isEmpty {
						HStack(alignment: .top, spacing: 8) {
							Image(systemName: "exclamationmark.triangle.fill")
								.foregroundColor(.wtcAlertRed)
							Text(errorMessage)
								.font(.wtcCaption)
								.foregroundColor(.wtcAlertRed)
								.fixedSize(horizontal: false, vertical: true)
						}
						.padding(8)
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(Color.wtcAlertRed.opacity(0.1))
						.cornerRadius(8)
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(12)
				.shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
				
				// Seção 2: Revisão do Comunicado
				VStack(alignment: .leading, spacing: 16) {
					HStack {
						Image(systemName: "square.and.pencil")
							.foregroundColor(.wtcPrimaryBlue)
						Text("Dados do Comunicado")
							.font(.wtcHeadline)
							.foregroundColor(.wtcPrimaryBlue)
						Spacer()
					}
					
					VStack(alignment: .leading, spacing: 6) {
						Text("Título da Campanha")
							.font(.wtcCaption)
							.foregroundColor(.gray)
						TextField("Digite ou gere com IA...", text: $title)
							.textFieldStyle(PlainTextFieldStyle())
							.padding()
							.background(Color.wtcLightGray)
							.cornerRadius(8)
							.font(.wtcBody)
					}
					
					VStack(alignment: .leading, spacing: 6) {
						Text("Corpo da Mensagem")
							.font(.wtcCaption)
							.foregroundColor(.gray)
						TextEditor(text: $message)
							.frame(height: 120)
							.padding(8)
							.background(Color.wtcLightGray)
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color.gray.opacity(0.1), lineWidth: 1)
							)
							.font(.wtcBody)
					}
					
					VStack(alignment: .leading, spacing: 6) {
						Text("URL do Banner (Imagem)")
							.font(.wtcCaption)
							.foregroundColor(.gray)
						TextField("https://...", text: $bannerUrl)
							.textFieldStyle(PlainTextFieldStyle())
							.padding()
							.background(Color.wtcLightGray)
							.cornerRadius(8)
							.font(.wtcBody)
					}
					
					VStack(alignment: .leading, spacing: 6) {
						Text("Segmento de Clientes")
							.font(.wtcCaption)
							.foregroundColor(.gray)
						Picker("Segmento", selection: $selectedSegment) {
							ForEach(segments, id: \.self) { segment in
								Text(segment)
							}
						}
						.pickerStyle(SegmentedPickerStyle())
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(12)
				.shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
				
				// Seção 3: Ações Sugeridas pela IA (Se houver)
				if !suggestedActions.isEmpty {
					VStack(alignment: .leading, spacing: 12) {
						HStack {
							Image(systemName: "hand.tap.fill")
								.foregroundColor(.wtcHighlightOrange)
							Text("Ações Interativas Geradas (Deep Links)")
								.font(.wtcHeadline)
								.foregroundColor(.wtcPrimaryBlue)
							Spacer()
						}
						
						Text("Estes botões serão acoplados ao banner no aplicativo SwiftUI para direcionar o cliente:")
							.font(.wtcCaption)
							.foregroundColor(.gray)
						
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 8) {
								ForEach(suggestedActions) { action in
									HStack(spacing: 6) {
										Image(systemName: "link.circle.fill")
											.foregroundColor(.white)
										VStack(alignment: .leading, spacing: 2) {
											Text(action.title)
												.font(.system(size: 13, weight: .bold))
												.foregroundColor(.white)
											Text(action.action)
												.font(.system(size: 9, weight: .semibold))
												.foregroundColor(.white.opacity(0.8))
										}
									}
									.padding(.horizontal, 12)
									.padding(.vertical, 8)
									.background(Color.wtcPrimaryBlue)
									.cornerRadius(16)
								}
							}
						}
					}
					.padding()
					.background(Color.white)
					.cornerRadius(12)
					.shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
				}
				
				// Feedbacks de Envio
				if isSent {
					HStack {
						Image(systemName: "checkmark.circle.fill")
							.foregroundColor(.wtcSuccessGreen)
						Text("Campanha disparada e enviada via Kafka com sucesso!")
							.font(.wtcHeadline)
							.foregroundColor(.wtcSuccessGreen)
					}
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.wtcSuccessGreen.opacity(0.1))
					.cornerRadius(8)
				}
				
				if !errorMessage.isEmpty {
					HStack {
						Image(systemName: "exclamationmark.triangle.fill")
							.foregroundColor(.wtcAlertRed)
						Text(errorMessage)
							.font(.wtcBody)
							.foregroundColor(.wtcAlertRed)
					}
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.wtcAlertRed.opacity(0.1))
					.cornerRadius(8)
				}
				
				// Botão de Disparo Final
				Button(action: sendCampaignReal) {
					HStack {
						if isSending {
							ProgressView()
								.progressViewStyle(CircularProgressViewStyle(tint: .white))
						} else {
							Image(systemName: "paperplane.fill")
								.font(.headline)
						}
						Text(isSending ? "Disparando..." : "🚀 Disparar Comunicado (Kafka)")
							.font(.wtcHeadline)
					}
					.foregroundColor(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 50)
					.background(title.isEmpty || message.isEmpty || isSending ? Color.gray : Color.wtcPrimaryBlue)
					.cornerRadius(12)
					.shadow(color: .black.opacity(0.1), radius: 5, y: 3)
				}
				.disabled(title.isEmpty || message.isEmpty || isSending)
				.padding(.bottom, 20)
			}
			.padding()
		}
		.background(Color.wtcLightGray.ignoresSafeArea())
		.navigationTitle("Novo Comunicado")
		.navigationBarTitleDisplayMode(.inline)
	}
	
	// CHAMA A IA NO SPRING BOOT (GEMINI)
	private func generateWithAI() {
		let text = briefing.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !text.isEmpty else { return }
		
		isAIGenerating = true
		errorMessage = ""
		
		Task {
			do {
				let campaign = try await NetworkManager.shared.generateCampaignWithAI(briefing: text)
				await MainActor.run {
					self.title = campaign.title
					self.message = campaign.body
					self.bannerUrl = campaign.url
					self.suggestedActions = campaign.actions
					self.suggestedActionUrls = campaign.actionUrls
					self.isAIGenerating = false
				}
			} catch {
				await MainActor.run {
					self.errorMessage = "Falha ao gerar com IA: \(error.localizedDescription)"
					self.isAIGenerating = false
				}
			}
		}
	}
	
	// DISPARA PARA O SPRING BOOT & KAFKA
	private func sendCampaignReal() {
		guard !title.isEmpty && !message.isEmpty else { return }
		
		isSending = true
		errorMessage = ""
		isSent = false
		
		// Mapear actions para array de strings para bater com o modelo do Kafka
		let actionList = suggestedActions.map { $0.action }
		
		Task {
			do {
				_ = try await NetworkManager.shared.createCampaign(
					title: title,
					body: message,
					urlString: bannerUrl,
					actions: actionList,
					actionUrls: suggestedActionUrls,
					segmentId: selectedSegment == "Todos" ? "SEG-ALL" : (selectedSegment == "Clientes VIP" ? "SEG-VIP" : "SEG-NEW")
				)
				
				await MainActor.run {
					lastAnnouncementTitle = title
					lastAnnouncementMessage = message
					isSent = true
					isSending = false
					
					// Limpar formulário após sucesso com atraso
					DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
						dismiss()
					}
				}
			} catch {
				await MainActor.run {
					self.errorMessage = "Falha ao disparar comunicados: \(error.localizedDescription)"
					self.isSending = false
				}
			}
		}
	}
}
