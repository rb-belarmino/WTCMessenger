import SwiftUI

struct CustomerTimelineView: View {
	let customerId: String

	@State private var timeline: CustomerTimeline? = nil
	@State private var isLoading = true
	@State private var errorMessage: String? = nil

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				if isLoading {
					VStack(spacing: 16) {
						Spacer()
						ProgressView("Carregando Timeline 360°...")
							.font(.wtcHeadline)
							.foregroundColor(.wtcSecondaryBlue)
						Spacer()
					}
					.frame(minHeight: 300)
				} else if let error = errorMessage {
					VStack(spacing: 16) {
						Image(systemName: "exclamationmark.triangle.fill")
							.font(.system(size: 48))
							.foregroundColor(.wtcAlertRed)
						Text(error)
							.font(.wtcHeadline)
							.foregroundColor(.wtcAlertRed)
							.multilineTextAlignment(.center)
							.padding(.horizontal)
						
						Button("Tentar Novamente") {
							Task {
								await loadTimeline()
							}
						}
						.font(.wtcHeadline)
						.foregroundColor(.white)
						.padding(.horizontal, 20)
						.padding(.vertical, 10)
						.background(Color.wtcPrimaryBlue)
						.cornerRadius(8)
					}
					.frame(minHeight: 300)
				} else if let timeline = timeline {
					// 1. Dados Básicos (Header Card)
					VStack(spacing: 8) {
						ZStack {
							Circle()
								.fill(LinearGradient(colors: [.wtcPrimaryBlue, .wtcSecondaryBlue], startPoint: .topLeading, endPoint: .bottomTrailing))
								.frame(width: 80, height: 80)
							Text(String(timeline.customer.name.prefix(2)).uppercased())
								.font(.system(size: 32, weight: .bold))
								.foregroundColor(.white)
						}
						.padding(.top, 16)
						
						Text(timeline.customer.name)
							.font(.wtcTitle)
							.foregroundColor(.wtcPrimaryBlue)
						
						Text(timeline.customer.email)
							.font(.wtcBody)
							.foregroundColor(.secondary)
						
						HStack(spacing: 12) {
							HStack(spacing: 4) {
								Image(systemName: "phone.fill")
								Text(timeline.customer.phone)
							}
							.font(.wtcCaption)
							.foregroundColor(.secondary)
							
							Text("•")
								.foregroundColor(.secondary)
							
							HStack(spacing: 4) {
								Image(systemName: "bolt.fill")
									.foregroundColor(.wtcHighlightOrange)
								Text(String(format: "%.1f", timeline.customer.engagementScore))
									.bold()
									.foregroundColor(.wtcHighlightOrange)
							}
							.font(.wtcCaption)
						}
						
						HStack(spacing: 6) {
							Text(timeline.customer.status.uppercased())
								.font(.system(size: 9, weight: .bold))
								.padding(.horizontal, 8)
								.padding(.vertical, 4)
								.background(isStatusActive(timeline.customer.status) ? Color.wtcSuccessGreen.opacity(0.15) : Color.gray.opacity(0.15))
								.foregroundColor(isStatusActive(timeline.customer.status) ? Color.wtcSuccessGreen : Color.gray)
								.cornerRadius(6)
							
							if let tags = timeline.customer.tags {
								ForEach(tags, id: \.self) { tag in
									Text(tag)
										.font(.system(size: 9, weight: .bold))
										.padding(.horizontal, 8)
										.padding(.vertical, 4)
										.background(Color.wtcSecondaryBlue.opacity(0.15))
										.foregroundColor(.wtcPrimaryBlue)
										.cornerRadius(6)
								}
							}
						}
						.padding(.bottom, 16)
					}
					.frame(maxWidth: .infinity)
					.background(Color.white)
					.cornerRadius(16)
					.shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
					.padding(.horizontal)
					.padding(.top, 12)

					// 2. Tarefas Pendentes do CRM (Dados do Spring Boot Service)
					VStack(alignment: .leading, spacing: 12) {
						HStack {
							Image(systemName: "checklist")
								.foregroundColor(.wtcHighlightOrange)
							Text("Ações Pendentes do Operador")
								.font(.wtcHeadline)
								.foregroundColor(.wtcPrimaryBlue)
						}
						.padding(.horizontal)
						
						if timeline.openTasks.isEmpty {
							Text("Nenhuma ação operacional pendente para este cliente.")
								.font(.wtcBody)
								.foregroundColor(.gray)
								.padding()
								.frame(maxWidth: .infinity, alignment: .center)
								.background(Color.white)
								.cornerRadius(12)
								.shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
								.padding(.horizontal)
						} else {
							VStack(spacing: 10) {
								ForEach(timeline.openTasks, id: \.self) { task in
									HStack(spacing: 12) {
										ZStack {
											Circle()
												.fill(Color.wtcHighlightOrange.opacity(0.12))
												.frame(width: 32, height: 32)
											Image(systemName: "square.and.pencil")
												.font(.system(size: 14, weight: .bold))
												.foregroundColor(.wtcHighlightOrange)
										}
										
										Text(task)
											.font(.wtcBody)
											.foregroundColor(.wtcDarkGray)
											.lineLimit(3)
										
										Spacer()
									}
									.padding(12)
									.background(Color.white)
									.cornerRadius(12)
									.shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
								}
							}
							.padding(.horizontal)
						}
					}

					// 3. Histórico de Mensagens Recentes
					VStack(alignment: .leading, spacing: 12) {
						HStack {
							Image(systemName: "message.fill")
								.foregroundColor(.wtcPrimaryBlue)
							Text("Histórico de Mensagens Recentes")
								.font(.wtcHeadline)
								.foregroundColor(.wtcPrimaryBlue)
						}
						.padding(.horizontal)
						
						if timeline.recentMessages.isEmpty {
							Text("Nenhuma mensagem registrada para este cliente.")
								.font(.wtcBody)
								.foregroundColor(.gray)
								.padding()
								.frame(maxWidth: .infinity, alignment: .center)
								.background(Color.white)
								.cornerRadius(12)
								.shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
								.padding(.horizontal)
						} else {
							VStack(spacing: 12) {
								ForEach(timeline.recentMessages) { message in
									HStack(alignment: .top, spacing: 12) {
										// Ícone de Status
										ZStack {
											Circle()
												.fill(statusColor(message.status).opacity(0.12))
												.frame(width: 36, height: 36)
											Image(systemName: statusIcon(message.status))
												.font(.system(size: 14, weight: .bold))
												.foregroundColor(statusColor(message.status))
										}
										
										VStack(alignment: .leading, spacing: 6) {
											HStack {
												Text(message.type.uppercased())
													.font(.system(size: 9, weight: .bold))
													.padding(.horizontal, 6)
													.padding(.vertical, 2)
													.background(Color.wtcSecondaryBlue.opacity(0.15))
													.foregroundColor(.wtcPrimaryBlue)
													.cornerRadius(4)
												
												Spacer()
												
												Text(formatDate(message.createdAt))
													.font(.system(size: 10))
													.foregroundColor(.gray)
											}
											
											Text(message.content)
												.font(.wtcBody)
												.foregroundColor(.primary)
											
											HStack(spacing: 4) {
												Circle()
													.fill(statusColor(message.status))
													.frame(width: 6, height: 6)
												Text(message.status.rawValue.uppercased())
													.font(.system(size: 9, weight: .bold))
													.foregroundColor(statusColor(message.status))
											}
										}
									}
									.padding(14)
									.background(Color.white)
									.cornerRadius(12)
									.shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
								}
							}
							.padding(.horizontal)
						}
					}

					// 4. Campanhas Ativas
					VStack(alignment: .leading, spacing: 12) {
						Text("Campanhas Ativas")
							.font(.wtcHeadline)
							.foregroundColor(.wtcPrimaryBlue)
							.padding(.horizontal)
						
						if timeline.activeCampaigns.isEmpty {
							Text("Nenhuma campanha ativa associada a este cliente.")
								.font(.wtcBody)
								.foregroundColor(.gray)
								.padding()
								.frame(maxWidth: .infinity, alignment: .center)
								.background(Color.white)
								.cornerRadius(12)
								.shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
								.padding(.horizontal)
						} else {
							VStack(spacing: 12) {
								ForEach(timeline.activeCampaigns) { campaign in
									VStack(alignment: .leading, spacing: 12) {
										HStack {
											Text(campaign.title)
												.font(.wtcHeadline)
												.foregroundColor(.wtcPrimaryBlue)
											Spacer()
											Image(systemName: "megaphone.fill")
												.foregroundColor(.wtcHighlightOrange)
										}
										
										Text(campaign.body)
											.font(.wtcBody)
											.foregroundColor(.secondary)
										
										if !campaign.url.isEmpty, let imageUrl = URL(string: campaign.url) {
											AsyncImage(url: imageUrl) { image in
												image
													.resizable()
													.aspectRatio(contentMode: .fill)
													.frame(maxHeight: 140)
													.cornerRadius(8)
													.clipped()
											} placeholder: {
												ZStack {
													Color.gray.opacity(0.1)
													ProgressView()
												}
												.frame(height: 140)
												.cornerRadius(8)
											}
											.padding(.top, 4)
										}
										
										if !campaign.actions.isEmpty {
											ScrollView(.horizontal, showsIndicators: false) {
												HStack(spacing: 8) {
													ForEach(campaign.actions) { action in
														Button(action: {
															print("Campanha ação clicada: \(action.title)")
														}) {
															Text(action.title)
																.font(.system(size: 11, weight: .bold))
																.foregroundColor(.white)
																.padding(.horizontal, 12)
																.padding(.vertical, 6)
																.background(Color.wtcHighlightOrange)
																.cornerRadius(6)
														}
													}
												}
											}
											.padding(.top, 4)
										}
									}
									.padding(16)
									.background(Color.white)
									.cornerRadius(12)
									.shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
								}
							}
							.padding(.horizontal)
						}
					}
					.padding(.bottom, 24)
				}
			}
		}
		.background(Color.wtcLightGray.opacity(0.4).edgesIgnoringSafeArea(.all))
		.navigationTitle("Perfil 360°")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await loadTimeline()
		}
	}

	private func loadTimeline() async {
		isLoading = true
		errorMessage = nil
		do {
			let result = try await NetworkManager.shared.getCustomerTimeline(customerId: customerId)
			DispatchQueue.main.async {
				self.timeline = result
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}

	private func isStatusActive(_ status: String) -> Bool {
		let s = status.lowercased()
		return s == "active" || s == "ativo" || s == "active_customer"
	}

	private func statusColor(_ status: MessageStatus) -> Color {
		switch status {
		case .sent: return .blue
		case .delivered: return .wtcSecondaryBlue
		case .read: return .wtcSuccessGreen
		case .failed: return .wtcAlertRed
		}
	}

	private func statusIcon(_ status: MessageStatus) -> String {
		switch status {
		case .sent: return "paperplane.fill"
		case .delivered: return "checkmark"
		case .read: return "checkmark.seal.fill"
		case .failed: return "xmark.circle.fill"
		}
	}

	private func formatDate(_ dateString: String) -> String {
		let inputFormatter = ISO8601DateFormatter()
		inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		
		if let date = inputFormatter.date(from: dateString) {
			let outputFormatter = DateFormatter()
			outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
			return outputFormatter.string(from: date)
		}
		
		let simpleFormatter = DateFormatter()
		simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		if let date = simpleFormatter.date(from: dateString) {
			let outputFormatter = DateFormatter()
			outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
			return outputFormatter.string(from: date)
		}
		
		return dateString
	}
}
