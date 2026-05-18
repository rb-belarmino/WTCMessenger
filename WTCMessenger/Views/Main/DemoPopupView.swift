import SwiftUI

struct DemoPopupView: View {
	@State private var showAlert = false
	@State private var showPromoSheet = false
	@State private var showAnnouncementAlert = false
	
	@State private var simulatedCampaignTitle = "Campanha Relâmpago ⚡️"
	@State private var simulatedCampaignBody = "Olá! Aproveite frete grátis e 15% OFF em toda a loja usando o cupom WTC15 nas próximas 2 horas!"
	@State private var simulatedLink = "https://wtcmessenger.com/promo"
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				
				// Header
				VStack(spacing: 8) {
					Text("Painel de Simulações")
						.font(.wtcTitle)
						.foregroundColor(.wtcPrimaryBlue)
					
					Text("CAMPANHAS E POPUPS EM SANDBOX")
						.font(.wtcCaption)
						.foregroundColor(.wtcHighlightOrange)
						.tracking(1.5)
				}
				.padding(.top)
				
				// Seção 1: Simulador de Push Rich Notification
				VStack(alignment: .leading, spacing: 16) {
					HStack {
						Image(systemName: "bell.badge.fill")
							.foregroundColor(.wtcHighlightOrange)
						Text("Simulador de Notificações Rich Push")
							.font(.wtcHeadline)
							.foregroundColor(.wtcPrimaryBlue)
					}
					
					Text("Visualize como uma campanha disparada pelo Kafka é renderizada no dispositivo do cliente:")
						.font(.wtcCaption)
						.foregroundColor(.gray)
					
					// Card do Rich Push (Design Premium que simula o iOS Banner)
					VStack(alignment: .leading, spacing: 8) {
						HStack {
							Image(systemName: "message.circle.fill")
								.foregroundColor(.wtcHighlightOrange)
								.font(.title3)
							Text("WTC Messenger")
								.font(.system(size: 13, weight: .bold))
								.foregroundColor(.wtcDarkGray)
							Spacer()
							Text("Agora")
								.font(.system(size: 11))
								.foregroundColor(.gray)
						}
						
						Text(simulatedCampaignTitle)
							.font(.system(size: 14, weight: .semibold))
							.foregroundColor(.wtcPrimaryBlue)
						
						Text(simulatedCampaignBody)
							.font(.system(size: 13))
							.foregroundColor(.wtcDarkGray)
							.lineLimit(2)
						
						// Ações Interativas do Rich Push
						HStack(spacing: 12) {
							Button(action: {
								showPromoSheet = true
							}) {
								Text("Abrir Oferta")
									.font(.system(size: 12, weight: .bold))
									.foregroundColor(.white)
									.padding(.vertical, 8)
									.padding(.horizontal, 16)
									.background(Color.wtcHighlightOrange)
									.cornerRadius(8)
							}
							
							Button(action: {
								showAlert = true
							}) {
								Text("Ignorar")
									.font(.system(size: 12, weight: .medium))
									.foregroundColor(.gray)
									.padding(.vertical, 8)
									.padding(.horizontal, 16)
									.background(Color.wtcLightGray)
									.cornerRadius(8)
							}
						}
						.padding(.top, 4)
					}
					.padding()
					.background(Color.wtcLightGray.opacity(0.5))
					.cornerRadius(12)
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color.wtcHighlightOrange.opacity(0.3), lineWidth: 1)
					)
				}
				.padding()
				.background(Color.white)
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
				.padding(.horizontal)
				
				// Seção 2: Testes Rápidos de Alertas CRM
				VStack(alignment: .leading, spacing: 16) {
					HStack {
						Image(systemName: "bolt.fill")
							.foregroundColor(.wtcPrimaryBlue)
						Text("Testes Rápidos de Modais")
							.font(.wtcHeadline)
							.foregroundColor(.wtcPrimaryBlue)
					}
					
					Text("Dispare alertas visuais locais para validar as rotinas e fluxos operacionais:")
						.font(.wtcCaption)
						.foregroundColor(.gray)
					
					VStack(spacing: 12) {
						// Botão 1: Alerta Clássico
						Button(action: {
							showAnnouncementAlert = true
						}) {
							HStack {
								Image(systemName: "megaphone.fill")
									.foregroundColor(.wtcPrimaryBlue)
								Text("Disparar Comunicado (Alert)")
									.font(.wtcBody)
									.foregroundColor(.wtcDarkGray)
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundColor(.gray)
							}
							.padding()
							.background(Color.wtcLightGray.opacity(0.4))
							.cornerRadius(10)
						}
						
						// Botão 2: Modal Rich Sheet
						Button(action: {
							showPromoSheet = true
						}) {
							HStack {
								Image(systemName: "doc.text.fill")
									.foregroundColor(.wtcHighlightOrange)
								Text("Visualizar Landing Page (Sheet)")
									.font(.wtcBody)
									.foregroundColor(.wtcDarkGray)
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundColor(.gray)
							}
							.padding()
							.background(Color.wtcLightGray.opacity(0.4))
							.cornerRadius(10)
						}
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
				.padding(.horizontal)
				
				// Seção 3: Informações da Sandbox
				VStack(alignment: .leading, spacing: 8) {
					Text("Área de Teste Segura")
						.font(.wtcHeadline)
						.foregroundColor(.wtcPrimaryBlue)
					Text("Nenhuma ação realizada neste painel interfere na produção ou publica eventos reais no broker Kafka. Sinta-se livre para simular e demonstrar a arquitetura reativa para clientes e investidores.")
						.font(.wtcCaption)
						.foregroundColor(.gray)
						.lineSpacing(4)
				}
				.padding()
				.background(Color.white)
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
				.padding(.horizontal)
				.padding(.bottom, 24)
			}
		}
		.background(Color.wtcLightGray.opacity(0.6).edgesIgnoringSafeArea(.all))
		
		// Modais e Triggers do Painel
		.alert("Status do Disparo", isPresented: $showAlert) {
			Button("Ok", role: .cancel) { }
		} message: {
			Text("Campanha simulada arquivada localmente com sucesso!")
		}
		.alert("🔔 Comunicado Importante", isPresented: $showAnnouncementAlert) {
			Button("Entendido", role: .cancel) { }
		} message: {
			Text("O servidor WTC local está monitorando a fila do Kafka com sucesso. Conexões de rede ativas.")
		}
		.sheet(isPresented: $showPromoSheet) {
			VStack(spacing: 20) {
				Capsule()
					.fill(Color.gray.opacity(0.3))
					.frame(width: 40, height: 6)
					.padding(.top, 8)
				
				Text("WTC Promo Landing Page")
					.font(.wtcTitle)
					.foregroundColor(.wtcPrimaryBlue)
				
				Image(systemName: "cart.fill.badge.questionmark")
					.font(.system(size: 60))
					.foregroundColor(.wtcHighlightOrange)
					.padding()
				
				Text(simulatedCampaignTitle)
					.font(.wtcHeadline)
					.foregroundColor(.wtcPrimaryBlue)
				
				Text(simulatedCampaignBody)
					.font(.wtcBody)
					.foregroundColor(.wtcDarkGray)
					.multilineTextAlignment(.center)
					.padding(.horizontal)
				
				Link("Acessar Link da Campanha", destination: URL(string: simulatedLink)!)
					.font(.wtcHeadline)
					.foregroundColor(.white)
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.wtcHighlightOrange)
					.cornerRadius(10)
					.padding(.horizontal)
				
				Button("Fechar Visualização") {
					showPromoSheet = false
				}
				.font(.wtcBody)
				.foregroundColor(.gray)
				.padding(.bottom)
			}
			.padding()
			.background(Color.white)
		}
	}
}
