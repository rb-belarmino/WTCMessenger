# WTCMessenger

WTCMessenger é um aplicativo de mensagens e CRM desenvolvido em SwiftUI, com autenticação via Auth-Service (Spring Boot + JWT), gerenciamento de conversas, envio de comunicados via Apache Kafka e persistência em nuvem com MongoDB.

## Funcionalidades

- **Autenticação de Usuário:**  
  Login com seleção de papel (operador ou cliente), utilizando o Auth-Service (Spring Boot + JWT) e MongoDB.

- **Feed de Conversas:**  
  Visualização de conversas, envio de novas mensagens, abertura de chat individual.

- **Envio de Mensagens:**  
  Tela customizada para envio de mensagens, seguindo o Design System do app.

- **CRM de Anotações:**  
  Adição, visualização detalhada e remoção de anotações vinculadas a clientes.

- **Envio de Comunicados (Copiloto de IA):**  
  Operadores podem usar Inteligência Artificial (Gemini) no aplicativo para gerar briefings estruturados e disparar campanhas ricas via fila de mensagens Kafka.

- **Busca de Usuários:**  
  Ferramenta para operadores localizarem usuários no sistema.

- **Design System:**  
  Cores, fontes e espaçamentos centralizados para padronização visual.

## Estrutura do Projeto

- `Views/`  
  Contém as telas principais: Login, MainView, ChatView, NoteDetailView, AnnouncementSendView, etc.

- `DesignSystem.swift`  
  Define cores, fontes e estilos reutilizáveis.

- `Core/`  
  - `WTCMessengerIntegration.swift`: Concentra o `NetworkManager` e os modelos decodificáveis do sistema para integração robusta com o backend Spring Boot.

- `Models/`  
  Estruturas de dados como `Conversation`, `Note`, `Campaign`, etc.

## Como rodar

1. **Pré-requisitos:**  
   - Xcode 14+  
   - Swift 5.7+  
   - Backend rodando localmente (`docker-compose up -d` no repositório backend)

2. **Configuração:**  
   - Clone o repositório:  
     `git clone <url-do-repo>`
   - Abra o projeto no Xcode.
   - O aplicativo já está configurado para apontar para as portas padrão do Docker local (`8080` para Autenticação e `8082` para Mensageria).

3. **Execução:**  
   - Selecione um simulador ou dispositivo.
   - Clique em **Run** (⌘R).

## Fluxo de Telas

- **Login:**  
  Usuário faz login com e-mail/senha salvos no MongoDB e seleciona papel.
- **Feed:**  
  Visualiza conversas, envia mensagens.
- **CRM:**  
  Adiciona e gerencia anotações de clientes.
- **Perfil:**  
  Visualiza e faz logout.

## Design System

- **Cores:**  
  - `wtcPrimaryBlue`, `wtcHighlightOrange`, `wtcLightGray`, etc.
- **Fontes:**  
  - `wtcTitle`, `wtcBody`, `wtcCaption`, etc.

## Contribuição

1. Faça um fork do projeto.
2. Crie uma branch: `git checkout -b minha-feature`
3. Commit suas alterações: `git commit -m 'feat: minha feature'`
4. Push para o fork: `git push origin minha-feature`
5. Abra um Pull Request.

## Licença

Este projeto está sob a licença MIT.

---

**Desenvolvido por Rodrigo Belarmino**
