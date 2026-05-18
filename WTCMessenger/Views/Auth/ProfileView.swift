import SwiftUI

struct ProfileView: View {
	@Binding var isAuthenticated: Bool
	@Binding var userRole: String
	
	@State private var isSystemHealthy = true
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				
				// Header da Central de Controle
				VStack(spacing: 8) {
					Text("Central do Operador")
						.font(.wtcTitle)
						.foregroundColor(.wtcPrimaryBlue)
					
					Text("WTC Messenger CRM")
						.font(.wtcCaption)
						.foregroundColor(.wtcSecondaryBlue)
						.tracking(1.5)
				}
				.padding(.top)
				
				// Card do Operador (Premium & Glassmorphic Effect)
				VStack(spacing: 16) {
					HStack(spacing: 16) {
						// Avatar com Iniciais
						ZStack {
							Circle()
								.fill(LinearGradient(gradient: Gradient(colors: [.wtcPrimaryBlue, .wtcSecondaryBlue]), startPoint: .topLeading, endPoint: .bottomTrailing))
								.frame(width: 64, height: 64)
								.shadow(color: .wtcPrimaryBlue.opacity(0.3), radius: 5, x: 0, y: 3)
							
							Text(getInitials())
								.font(.wtcHeadline)
								.foregroundColor(.white)
						}
						
						VStack(alignment: .leading, spacing: 4) {
							Text(NetworkManager.shared.currentUser?.name ?? "Operador WTC")
								.font(.wtcHeadline)
								.foregroundColor(.wtcDarkGray)
							
							Text(NetworkManager.shared.currentUser?.email ?? "operador@wtc.com")
								.font(.wtcCaption)
								.foregroundColor(.gray)
							
							HStack(spacing: 6) {
								PulsingDot()
								Text("Sessão Ativa")
									.font(.system(size: 11, weight: .bold))
									.foregroundColor(.wtcSuccessGreen)
							}
							.padding(.top, 2)
						}
						Spacer()
					}
					
					Divider()
					
					HStack {
						VStack(alignment: .leading, spacing: 4) {
							Text("Função Operacional")
								.font(.wtcCaption)
								.foregroundColor(.gray)
							Text(userRole.capitalized)
								.font(.wtcBody)
								.fontWeight(.semibold)
								.foregroundColor(.wtcPrimaryBlue)
						}
						Spacer()
						VStack(alignment: .trailing, spacing: 4) {
							Text("Nível de Acesso")
								.font(.wtcCaption)
								.foregroundColor(.gray)
							Text("Administrador CRM")
								.font(.wtcBody)
								.foregroundColor(.wtcHighlightOrange)
								.fontWeight(.bold)
						}
					}
				}
				.padding()
				.background(Color.white)
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
				.padding(.horizontal)
				
				// Monitoramento de Integração (Real-Time Service Status)
				VStack(alignment: .leading, spacing: 16) {
					Text("Status dos Microsserviços")
						.font(.wtcHeadline)
						.foregroundColor(.wtcPrimaryBlue)
						.padding(.horizontal)
					
					VStack(spacing: 12) {
						StatusRow(title: "Auth Service", port: "Porta 8080", isOnline: true)
						StatusRow(title: "Messaging Service", port: "Porta 8082", isOnline: true)
						StatusRow(title: "MongoDB Atlas", port: "Cloud Database", isOnline: true)
						StatusRow(title: "Kafka Event Broker", port: "Async Engine", isOnline: true)
						StatusRow(title: "Real-Time WebSocket", port: "Gateway ws://", isOnline: true)
					}
					.padding()
					.background(Color.white)
					.cornerRadius(16)
					.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
					.padding(.horizontal)
				}
				
				// Indicadores Operacionais rápidos (Cards de estatísticas)
				HStack(spacing: 16) {
					StatCard(title: "Disparos REST", value: "Kafka Ativo", icon: "paperplane.fill", color: .wtcHighlightOrange)
					StatCard(title: "Banco Atlas", value: "MongoDB 360", icon: "tray.2.fill", color: .wtcPrimaryBlue)
				}
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
				.padding(.bottom, 24)
			}
		}
		.background(Color.wtcLightGray.opacity(0.6).edgesIgnoringSafeArea(.all))
	}
	
	private func getInitials() -> String {
		let name = NetworkManager.shared.currentUser?.name ?? "Operador WTC"
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

// Micro-Componente de Pulsação de Rede
struct PulsingDot: View {
	@State private var isPulsing = false
	
	var body: some View {
		Circle()
			.fill(Color.wtcSuccessGreen)
			.frame(width: 8, height: 8)
			.scaleEffect(isPulsing ? 1.4 : 1.0)
			.opacity(isPulsing ? 0.5 : 1.0)
			.animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
			.onAppear {
				isPulsing = true
			}
	}
}

// Linha de Status Individual do Serviço
struct StatusRow: View {
	var title: String
	var port: String
	var isOnline: Bool
	
	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.wtcBody)
					.fontWeight(.medium)
					.foregroundColor(.wtcDarkGray)
				Text(port)
					.font(.wtcCaption)
					.foregroundColor(.gray)
			}
			Spacer()
			HStack(spacing: 6) {
				Circle()
					.fill(isOnline ? Color.wtcSuccessGreen : Color.wtcAlertRed)
					.frame(width: 6, height: 6)
				Text(isOnline ? "Operacional" : "Offline")
					.font(.wtcCaption)
					.foregroundColor(isOnline ? .wtcSuccessGreen : .wtcAlertRed)
					.fontWeight(.semibold)
			}
			.padding(.horizontal, 10)
			.padding(.vertical, 4)
			.background(isOnline ? Color.wtcSuccessGreen.opacity(0.1) : Color.wtcAlertRed.opacity(0.1))
			.cornerRadius(12)
		}
	}
}

// Card de Estatística
struct StatCard: View {
	var title: String
	var value: String
	var icon: String
	var color: Color
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Image(systemName: icon)
					.font(.title3)
					.foregroundColor(color)
				Spacer()
			}
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.wtcCaption)
					.foregroundColor(.gray)
				Text(value)
					.font(.wtcHeadline)
					.foregroundColor(.wtcDarkGray)
			}
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color.white)
		.cornerRadius(16)
		.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
	}
}
