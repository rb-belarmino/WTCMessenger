import SwiftUI

struct UserSearchView: View {
	@State private var searchText = ""
	@State private var customers: [Customer] = []
	@State private var isLoading = false
	@State private var errorMessage: String? = nil

	var filteredCustomers: [Customer] {
		if searchText.isEmpty {
			return customers
		} else {
			return customers.filter { customer in
				customer.name.localizedCaseInsensitiveContains(searchText) ||
				customer.email.localizedCaseInsensitiveContains(searchText)
			}
		}
	}

	var body: some View {
		VStack(spacing: 0) {
			// Campo de busca com design do WTC
			HStack {
				Image(systemName: "magnifyingglass")
					.foregroundColor(.gray)
				TextField("Buscar clientes por nome ou e-mail...", text: $searchText)
					.font(.wtcBody)
					.foregroundColor(.primary)
				if !searchText.isEmpty {
					Button(action: { searchText = "" }) {
						Image(systemName: "xmark.circle.fill")
							.foregroundColor(.gray)
					}
				}
			}
			.padding(12)
			.background(Color.wtcLightGray)
			.cornerRadius(10)
			.padding(.horizontal)
			.padding(.top, 12)
			.padding(.bottom, 8)

			if isLoading && customers.isEmpty {
				Spacer()
				ProgressView("Carregando clientes...")
					.font(.wtcBody)
					.foregroundColor(.wtcSecondaryBlue)
				Spacer()
			} else if let error = errorMessage {
				Spacer()
				VStack(spacing: 16) {
					Image(systemName: "exclamationmark.triangle.fill")
						.font(.system(size: 48))
						.foregroundColor(.wtcAlertRed)
					Text(error)
						.font(.wtcHeadline)
						.foregroundColor(.wtcAlertRed)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
					
					Button(action: {
						Task {
							await fetchCustomers()
						}
					}) {
						Text("Tentar Novamente")
							.font(.wtcHeadline)
							.foregroundColor(.white)
							.padding(.horizontal, 20)
							.padding(.vertical, 10)
							.background(Color.wtcPrimaryBlue)
							.cornerRadius(8)
					}
				}
				Spacer()
			} else if filteredCustomers.isEmpty {
				Spacer()
				VStack(spacing: 12) {
					Image(systemName: "person.crop.circle.badge.questionmark")
						.font(.system(size: 64))
						.foregroundColor(.gray)
					Text(searchText.isEmpty ? "Nenhum cliente cadastrado no momento." : "Nenhum cliente correspondente encontrado.")
						.font(.wtcBody)
						.foregroundColor(.gray)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
				}
				Spacer()
			} else {
				// Lista de clientes
				List(filteredCustomers) { customer in
					NavigationLink(destination: CustomerTimelineView(customerId: customer.id)) {
						HStack(spacing: 16) {
							// Iniciais do Cliente como Avatar
							ZStack {
								Circle()
									.fill(Color.wtcPrimaryBlue.opacity(0.1))
									.frame(width: 48, height: 48)
								Text(String(customer.name.prefix(2)).uppercased())
									.font(.wtcHeadline)
									.foregroundColor(.wtcPrimaryBlue)
							}

							VStack(alignment: .leading, spacing: 4) {
								Text(customer.name)
									.font(.wtcHeadline)
									.foregroundColor(.wtcPrimaryBlue)
								Text(customer.email)
									.font(.wtcBody)
									.foregroundColor(.secondary)
								
								if let tags = customer.tags, !tags.isEmpty {
									HStack(spacing: 6) {
										ForEach(tags, id: \.self) { tag in
											Text(tag)
												.font(.system(size: 10, weight: .semibold))
												.padding(.horizontal, 6)
												.padding(.vertical, 2)
												.background(Color.wtcSecondaryBlue.opacity(0.15))
												.foregroundColor(.wtcPrimaryBlue)
												.cornerRadius(4)
										}
									}
									.padding(.top, 2)
								}
							}
							
							Spacer()
							
							VStack(alignment: .trailing, spacing: 6) {
								// Score de Engajamento
								HStack(spacing: 4) {
									Image(systemName: "bolt.fill")
										.font(.system(size: 12))
										.foregroundColor(.wtcHighlightOrange)
									Text(String(format: "%.1f", customer.engagementScore))
										.font(.wtcCaption)
										.bold()
										.foregroundColor(.wtcHighlightOrange)
								}
								.padding(.horizontal, 8)
								.padding(.vertical, 4)
								.background(Color.wtcHighlightOrange.opacity(0.12))
								.cornerRadius(12)
								
								// Status Badge
								Text(customer.status.uppercased())
									.font(.system(size: 9, weight: .bold))
									.padding(.horizontal, 6)
									.padding(.vertical, 2)
									.background(isStatusActive(customer.status) ? Color.wtcSuccessGreen.opacity(0.15) : Color.gray.opacity(0.15))
									.foregroundColor(isStatusActive(customer.status) ? Color.wtcSuccessGreen : Color.gray)
									.cornerRadius(4)
							}
						}
						.padding(.vertical, 4)
					}
				}
				.listStyle(PlainListStyle())
				.refreshable {
					await fetchCustomers()
				}
			}
		}
		.navigationTitle("Buscar Clientes")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await fetchCustomers()
		}
	}

	private func fetchCustomers() async {
		isLoading = true
		errorMessage = nil
		do {
			let result = try await NetworkManager.shared.getCustomers()
			DispatchQueue.main.async {
				self.customers = result
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
}
