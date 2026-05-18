import Foundation
import Combine

// MARK: - API Response Wrappers
/// Estrutura genérica para interpretar o padrão de respostas de sucesso (ApiResponse) do seu Spring Boot.
struct ApiResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
    let timestamp: String
}

/// Estrutura para capturar erros retornados pelo GlobalExceptionHandler em português brasileiro.
struct ApiErrorPayload: Codable, LocalizedError {
    let timestamp: String
    let status: Int
    let code: String
    let message: String
    
    var errorDescription: String? {
        return message // Retorna diretamente a mensagem amigável em PT-BR para a UI do iOS
    }
}

// MARK: - Domain Models (Mapeamento do MongoDB)
enum UserRole: String, Codable {
    case operatorRole = "OPERATOR"
    case customerRole = "CLIENTE"
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let role: String
}

// MARK: - Auxiliares de Tipo Dinâmico
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doubleVal = try? container.decode(Double.self) {
            self.value = doubleVal
        } else if let stringVal = try? container.decode(String.self) {
            self.value = stringVal
        } else if let boolVal = try? container.decode(Bool.self) {
            self.value = boolVal
        } else if let arrayVal = try? container.decode([String].self) {
            self.value = arrayVal
        } else {
            self.value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let arrayVal = value as? [String] {
            try container.encode(arrayVal)
        }
    }
}

struct Customer: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let tags: [String]?
    let engagementScore: Double
    let status: String
    let segmentId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, tags, engagementScore, status, segmentId, additionalAttributes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.segmentId = try container.decodeIfPresent(String.self, forKey: .segmentId)
        
        let additional = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .additionalAttributes)
        
        // Decode tags safely
        if let decodedTags = try container.decodeIfPresent([String].self, forKey: .tags) {
            self.tags = decodedTags
        } else if let tagsArray = additional?["tags"]?.value as? [String] {
            self.tags = tagsArray
        } else {
            self.tags = ["Premium", "Fidelidade"]
        }
        
        // Decode engagementScore safely
        if let decodedScore = try container.decodeIfPresent(Double.self, forKey: .engagementScore) {
            self.engagementScore = decodedScore
        } else {
            var scoreFound: Double? = nil
            if let scoreVal = additional?["engagementScore"]?.value as? Double {
                scoreFound = scoreVal
            } else if let scoreStr = additional?["engagementScore"]?.value as? String, let scoreDouble = Double(scoreStr) {
                scoreFound = scoreDouble
            }
            self.engagementScore = scoreFound ?? 8.5
        }
        
        // Decode status safely
        if let decodedStatus = try container.decodeIfPresent(String.self, forKey: .status) {
            self.status = decodedStatus
        } else {
            var statusFound: String? = nil
            if let statusStr = additional?["status"]?.value as? String {
                statusFound = statusStr
            }
            self.status = statusFound ?? "ativo"
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encode(engagementScore, forKey: .engagementScore)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(segmentId, forKey: .segmentId)
    }
}

enum MessageStatus: String, Codable {
    case sent = "SENT"
    case delivered = "DELIVERED"
    case read = "READ"
    case failed = "FAILED"
}

struct Message: Codable, Identifiable {
    let id: String
    let senderId: String?
    let recipientId: String
    let content: String
    let type: String
    let status: MessageStatus
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, senderId, recipientId, content, type, status, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.senderId = try container.decodeIfPresent(String.self, forKey: .senderId)
        
        // Decode recipientId safely
        if let rec = try container.decodeIfPresent(String.self, forKey: .recipientId) {
            self.recipientId = rec
        } else {
            self.recipientId = ""
        }
        
        // Decode content safely
        if let cont = try container.decodeIfPresent(String.self, forKey: .content) {
            self.content = cont
        } else {
            self.content = ""
        }
        
        // Decode type safely
        if let ty = try container.decodeIfPresent(String.self, forKey: .type) {
            self.type = ty
        } else {
            self.type = "CHAT"
        }
        
        // Decode status safely
        if let stat = try container.decodeIfPresent(MessageStatus.self, forKey: .status) {
            self.status = stat
        } else {
            self.status = .sent
        }
        
        // Decode createdAt safely
        if let created = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            self.createdAt = created
        } else {
            // ISO8601 string padrão caso seja nulo no banco
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.createdAt = formatter.string(from: Date())
        }
    }
}

/// Estrutura de Campanha com suporte a modelos ricos de IA gerados pelo Copiloto (Spring AI)
struct CampaignAction: Codable, Identifiable {
    var id: String { action }
    let action: String
    let title: String
}

struct Campaign: Codable, Identifiable {
    private let rawId: String?
    let title: String
    let body: String
    private let rawUrl: String?
    private let rawActions: [CampaignAction]?
    private let rawActionUrls: [String: String]?
    
    var id: String {
        return rawId ?? title
    }
    
    var url: String {
        return rawUrl ?? "https://via.placeholder.com/600x300"
    }
    
    var actions: [CampaignAction] {
        return rawActions ?? []
    }
    
    var actionUrls: [String: String] {
        return rawActionUrls ?? [:]
    }
    
    enum CodingKeys: String, CodingKey {
        case rawId = "id"
        case title
        case body
        case rawUrl = "url"
        case rawActions = "actions"
        case rawActionUrls = "actionUrls"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rawId = try container.decodeIfPresent(String.self, forKey: .rawId)
        self.title = try container.decode(String.self, forKey: .title)
        
        // Tenta decodificar de "body", se não achar tenta "content"
        if let bodyValue = try container.decodeIfPresent(String.self, forKey: .body) {
            self.body = bodyValue
        } else {
            struct DynamicKeys: CodingKey {
                var stringValue: String
                var intValue: Int?
                init?(stringValue: String) { self.stringValue = stringValue }
                init?(intValue: Int) { return nil }
            }
            let dynamicContainer = try decoder.container(keyedBy: DynamicKeys.self)
            if let contentKey = DynamicKeys(stringValue: "content"),
               let contentValue = try dynamicContainer.decodeIfPresent(String.self, forKey: contentKey) {
                self.body = contentValue
            } else {
                self.body = try container.decode(String.self, forKey: .body)
            }
        }
        
        self.rawUrl = try container.decodeIfPresent(String.self, forKey: .rawUrl)
        
        // Decodificação super robusta de rawActions: suporta [CampaignAction] e [String]
        if let actionsArray = try? container.decode([CampaignAction].self, forKey: .rawActions) {
            self.rawActions = actionsArray
        } else if let stringsArray = try? container.decode([String].self, forKey: .rawActions) {
            self.rawActions = stringsArray.map { actionStr in
                let title = actionStr.contains("confirmar") ? "Confirmar Presença" :
                            (actionStr.contains("agenda") ? "Ver Agenda" : "Acessar Link")
                return CampaignAction(action: actionStr, title: title)
            }
        } else {
            self.rawActions = nil
        }
        
        self.rawActionUrls = try container.decodeIfPresent([String: String].self, forKey: .rawActionUrls)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(rawId, forKey: .rawId)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encodeIfPresent(rawUrl, forKey: .rawUrl)
        try container.encodeIfPresent(rawActions, forKey: .rawActions)
        try container.encodeIfPresent(rawActionUrls, forKey: .rawActionUrls)
    }
}

struct CustomerTimeline: Codable {
    let customer: Customer
    let recentMessages: [Message]
    let activeCampaigns: [Campaign]
    let openTasks: [String]
}

// MARK: - Network Manager (REST HTTP Client)
/// Gerenciador de requisições HTTP REST responsável pela integração com os microsserviços.
@MainActor class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // ATENÇÃO: DEFINA AQUI O IP DA SUA MÁQUINA CASO RODE EM DISPOSITIVO FÍSICO (Ex: "192.168.1.50")
    private let host = "localhost"
    
    private var authBaseURL: String { "http://\(host):8080/auth" }
    private var messagingBaseURL: String { "http://\(host):8082" }
    
    @Published var currentUser: User? = nil
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil
    
    private init() {}
    
    /// Define cabeçalhos padrão incluindo o Token JWT caso o usuário já esteja logado.
    private func defaultHeaders() -> [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    // MARK: - Autenticação (Auth Service - Porta 8080)
    
    /// Realiza o login na base de dados MongoDB do Auth-Service.
    func login(email: String, password: [Character]) async throws -> User {
        guard let url = URL(string: "\(authBaseURL)/login") else {
            throw URLError(.badURL)
        }
        
        // Converte o array de caracteres para String para envio no JSON
        let passwordString = String(password)
        let body: [String: String] = ["email": email, "password": passwordString]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            // O backend retorna o LoginResponse direto na raiz do JSON, sem ApiResponse wrap
            let loginData = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Converte a string role do backend ("OPERATOR") para a enum correspondente no Swift
            let userRole = UserRole(rawValue: loginData.role.uppercased()) ?? .operatorRole
            
            // Constrói o objeto de domínio User localmente com as informações conhecidas
            let user = User(
                id: email,
                name: "Admin Operator",
                email: email,
                role: userRole
            )
            
            DispatchQueue.main.async {
                self.accessToken = loginData.accessToken
                self.refreshToken = loginData.refreshToken
                self.currentUser = user
            }
            return user
        } else {
            // Decodifica a mensagem amigável em português lançada pelo Spring GlobalExceptionHandler
            if let apiError = try? JSONDecoder().decode(ApiErrorPayload.self, from: data) {
                throw apiError
            }
            throw NSError(domain: "WTCMessenger", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erro de autenticação no servidor."])
        }
    }
    
    /// Utiliza o Refresh Token para renovar as credenciais expiradas do usuário automaticamente.
    func refreshSession() async throws {
        guard let rToken = refreshToken, let url = URL(string: "\(authBaseURL)/refresh") else {
            throw URLError(.badURL)
        }
        
        let body = ["refreshToken": rToken]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let loginData = try JSONDecoder().decode(LoginResponse.self, from: data)
        DispatchQueue.main.async {
            self.accessToken = loginData.accessToken
            self.refreshToken = loginData.refreshToken
        }
    }
    
    // MARK: - CRM & Campanhas (Messaging Service - Porta 8082)
    
    /// Busca a lista de todos os clientes no MongoDB.
    func getCustomers() async throws -> [Customer] {
        guard let url = URL(string: "\(messagingBaseURL)/customers") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = defaultHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    /// Cria um novo cliente no MongoDB Atlas.
    func createCustomer(name: String, email: String, phone: String, tags: [String] = ["Premium"], engagementScore: Double = 8.5, status: String = "ativo") async throws -> Customer {
        guard let url = URL(string: "\(messagingBaseURL)/customers") else {
            throw URLError(.badURL)
        }
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "phone": phone,
            "additionalAttributes": [
                "tags": tags,
                "engagementScore": engagementScore,
                "status": status
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders()
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    /// Busca a timeline 360° unificada de um cliente específico no MongoDB.
    func getCustomerTimeline(customerId: String) async throws -> CustomerTimeline {
        guard let url = URL(string: "\(messagingBaseURL)/customers/\(customerId)/timeline") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = defaultHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    /// Dispara uma mensagem 1:1 utilizando o motor assíncrono Kafka.
    func sendMessage(recipientId: String, content: String, type: String = "CHAT") async throws {
        guard let url = URL(string: "\(messagingBaseURL)/messages") else {
            throw URLError(.badURL)
        }
        
        let body = [
            "recipientId": recipientId,
            "content": content,
            "type": type
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders()
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    /// CHAMA O COPILOTO DE INTELIGÊNCIA ARTIFICIAL (Spring AI) do Backend.
    func generateCampaignWithAI(briefing: String) async throws -> Campaign {
        guard let url = URL(string: "\(messagingBaseURL)/campaigns/generate") else {
            throw URLError(.badURL)
        }
        
        let body = ["prompt": briefing]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders()
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    /// ENVIA E DISPARA A CAMPANHA criada/revisada para o Spring Boot & Kafka.
    func createCampaign(title: String, body: String, urlString: String, actions: [String], actionUrls: [String: String], segmentId: String) async throws -> Campaign {
        guard let url = URL(string: "\(messagingBaseURL)/campaigns") else {
            throw URLError(.badURL)
        }
        
        let bodyPayload: [String: Any] = [
            "title": title,
            "content": body,
            "url": urlString,
            "actions": actions,
            "actionUrls": actionUrls,
            "segmentId": segmentId,
            "recipientIds": ["client-123", "client-456"] // Destinatários fictícios de exemplo
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders()
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyPayload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return try handleResponse(data: data, response: response)
    }
    
    // MARK: - Auxiliares de Tratamento de Resposta
    private func handleResponse<T: Codable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let apiResult = try JSONDecoder().decode(ApiResponse<T>.self, from: data)
            if let resultData = apiResult.data {
                return resultData
            } else {
                throw NSError(domain: "WTCMessenger", code: 404, userInfo: [NSLocalizedDescriptionKey: apiResult.message])
            }
        } else {
            if let apiError = try? JSONDecoder().decode(ApiErrorPayload.self, from: data) {
                throw apiError
            }
            throw NSError(domain: "WTCMessenger", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Falha na comunicação com o backend WTC."])
        }
    }
}

// MARK: - WebSocket Manager (Mensagens em Tempo Real)
/// Gerenciador de conexões persistentes bidirecionais (WebSockets) para a caixa de entrada em tempo real.
@MainActor class WebSocketManager: NSObject, URLSessionWebSocketDelegate, ObservableObject {
    static let shared = WebSocketManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let host = "localhost"
    
    @Published var incomingMessages: [Message] = []
    
    private override init() {
        super.init()
    }
    
    /// Conecta ao Handler nativo de WebSocket do Messaging-Service.
    func connect() {
        guard let token = NetworkManager.shared.accessToken else {
            print("❌ WebSocket recusado: Usuário precisa estar logado com JWT.")
            return
        }
        
        // Passa o Token JWT como Query Parameter para contornar limitações do iOS nos headers do Handshake.
        guard let url = URL(string: "ws://\(host):8082/chat?token=\(token)") else { return }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("🔌 WebSocket estabelecendo handshake com \(url.absoluteString)...")
        listenForMessages()
    }
    
    func disconnect() {
        let task = webSocketTask
        webSocketTask = nil
        task?.cancel(with: .normalClosure, reason: nil)
        print("🔌 WebSocket desconectado voluntariamente.")
    }
    
    /// Escuta os frames de mensagens continuamente (Pipeline Assíncrono do Kafka para o SwiftUI).
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                let nsError = error as NSError
                // Ignora cancelamentos voluntários (e.g. fechamento de tela) para evitar loop de reconexão
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                    return
                }
                
                // Ignora se o socket já foi definido como nulo (desconexão voluntária)
                guard self?.webSocketTask != nil else {
                    return
                }
                
                print("❌ Falha ao receber mensagem via WebSocket: \(error.localizedDescription)")
                // Tenta reconexão em 5 segundos
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    DispatchQueue.main.async {
                        self?.connect()
                    }
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.handleIncomingText(text)
                    }
                case .data(let data):
                    print("Received binary frame of size: \(data.count)")
                @unknown default:
                    break
                }
                DispatchQueue.main.async {
                    self?.listenForMessages() // Mantém o loop de escuta aberto
                }
            }
        }
    }
    
    private func handleIncomingText(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        do {
            let message = try JSONDecoder().decode(Message.self, from: data)
            self.incomingMessages.append(message)
            print("📩 Nova mensagem de chat recebida via WebSocket: \(message.content)")
        } catch {
            print("❌ Falha ao decodificar frame de WebSocket para objeto Message: \(error)")
        }
    }
}
