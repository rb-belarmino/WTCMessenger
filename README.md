# WTCMessenger

WTCMessenger é um aplicativo de mensagens e CRM desenvolvido em SwiftUI, com autenticação via Supabase, gerenciamento de conversas, envio de comunicados, busca de usuários e anotações de clientes.

## Funcionalidades

- **Autenticação de Usuário:**  
  Login com seleção de papel (operador ou cliente), utilizando Supabase.

- **Feed de Conversas:**  
  Visualização de conversas, envio de novas mensagens, abertura de chat individual.

- **Envio de Mensagens:**  
  Tela customizada para envio de mensagens, seguindo o Design System do app.

- **CRM de Anotações:**  
  Adição, visualização detalhada e remoção de anotações vinculadas a clientes.

- **Envio de Comunicados:**  
  Operadores podem enviar comunicados para usuários.

- **Busca de Usuários:**  
  Ferramenta para operadores localizarem usuários no sistema.

- **Design System:**  
  Cores, fontes e espaçamentos centralizados para padronização visual.

## Estrutura do Projeto

- `Views/`  
  Contém as telas principais: Login, MainView, ChatView, NoteDetailView, etc.

- `DesignSystem.swift`  
  Define cores, fontes e estilos reutilizáveis.

- `SupabaseManager.swift`  
  Gerencia autenticação e integração com Supabase.

- `Models/`  
  Estruturas de dados como `Conversation`, `Note`, etc.

## Como rodar

1. **Pré-requisitos:**  
   - Xcode 14+  
   - Swift 5.7+  
   - Conta no [Supabase](https://supabase.com/)

2. **Configuração:**  
   - Clone o repositório:  
     `git clone <url-do-repo>`
   - Abra o projeto no Xcode.
   - Configure as chaves do Supabase em `SupabaseManager.swift`.

3. **Execução:**  
   - Selecione um simulador ou dispositivo.
   - Clique em **Run** (⌘R).

## Fluxo de Telas

- **Login:**  
  Usuário faz login e seleciona papel.
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
