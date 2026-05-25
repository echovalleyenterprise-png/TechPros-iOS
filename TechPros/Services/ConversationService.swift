import Foundation

final class ConversationService {
    static let shared = ConversationService()
    private init() {}

    // MARK: - List

    func listConversations() async throws -> [ConversationListItem] {
        let resp: ConversationsResponse = try await APIClient.shared.get("/api/conversations")
        return resp.conversations
    }

    // MARK: - Create

    func createConversation(title: String? = nil) async throws -> String {
        struct Body: Encodable { let title: String? }
        let resp: ConversationResponse = try await APIClient.shared.post(
            "/api/conversations",
            body: Body(title: title)
        )
        return resp.conversation.id
    }

    // MARK: - Load messages

    func loadMessages(conversationId: String) async throws -> [ChatMessage] {
        let resp: MessagesResponse = try await APIClient.shared.get("/api/conversations/\(conversationId)")
        return resp.messages.map { stored in
            ChatMessage(
                id: stored.id,
                role: stored.role == "user" ? .user : .assistant,
                content: stored.content,
                timestamp: stored.createdAt
            )
        }
    }

    // MARK: - Delete

    func deleteConversation(id: String) async throws {
        try await APIClient.shared.delete("/api/conversations/\(id)")
    }
}
