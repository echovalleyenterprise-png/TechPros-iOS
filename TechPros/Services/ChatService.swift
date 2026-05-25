import Foundation

final class ChatService {
    static let shared = ChatService()
    private init() {}

    // MARK: - Chat Request payload

    private struct ChatRequest: Encodable {
        let messages: [APIMessage]
        let conversationId: String?
        let customerSafeMode: Bool
        let language: String
        let mode: String
    }

    // MARK: - Stream

    /// Returns an AsyncStream of text chunks. Throws if the request fails before streaming starts.
    func streamChat(
        messages: [ChatMessage],
        conversationId: String?,
        customerSafeMode: Bool,
        language: String,
        mode: String
    ) async throws -> AsyncThrowingStream<String, Error> {
        let apiMessages = buildAPIMessages(from: messages)
        let body = ChatRequest(
            messages: apiMessages,
            conversationId: conversationId,
            customerSafeMode: customerSafeMode,
            language: language,
            mode: mode
        )

        let (asyncBytes, response) = try await APIClient.shared.stream("/api/chat", body: body)

        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            throw APIError.unauthorized
        }

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var pendingData = Data()
                    for try await byte in asyncBytes {
                        pendingData.append(byte)
                        // Flush accumulated bytes as UTF-8 text every 8+ bytes
                        if pendingData.count >= 8 {
                            if let text = String(data: pendingData, encoding: .utf8) {
                                continuation.yield(text)
                                pendingData.removeAll(keepingCapacity: true)
                            }
                        }
                    }
                    // Final flush
                    if !pendingData.isEmpty, let text = String(data: pendingData, encoding: .utf8), !text.isEmpty {
                        continuation.yield(text)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Feedback

    func submitFeedback(messageId: String, rating: Int) async throws {
        struct Body: Encodable { let messageId: String; let rating: Int }
        struct Resp: Decodable { let success: Bool }
        let _: Resp = try await APIClient.shared.post("/api/feedback", body: Body(messageId: messageId, rating: rating))
    }

    // MARK: - Escalate

    struct EscalateMessage: Encodable {
        let role: String
        let content: String
        let timestamp: String
    }

    func escalate(messages: [ChatMessage], jobContext: String?, conversationId: String?) async throws {
        struct Body: Encodable {
            let messages: [EscalateMessage]
            let jobContext: String?
            let conversationId: String?
        }
        struct Resp: Decodable { let success: Bool }

        let iso = ISO8601DateFormatter()
        let payload = messages.map {
            EscalateMessage(role: $0.role.rawValue, content: $0.content, timestamp: iso.string(from: $0.timestamp))
        }
        let _: Resp = try await APIClient.shared.post(
            "/api/escalate",
            body: Body(messages: payload, jobContext: jobContext, conversationId: conversationId)
        )
    }

    // MARK: - Save SOP

    func saveSOP(title: String, content: String, brand: String = "general", model: String = "", deviceType: String = "general") async throws {
        struct Body: Encodable {
            let title, content, brand, model: String
            // swiftlint:disable:next identifier_name
            let device_type: String
        }
        struct Resp: Decodable { let success: Bool; let document_id: String?; let chunks: Int? }
        let _: Resp = try await APIClient.shared.post(
            "/api/knowledge/save",
            body: Body(title: title, content: content, brand: brand, model: model, device_type: deviceType)
        )
    }

    // MARK: - Helpers

    private func buildAPIMessages(from messages: [ChatMessage]) -> [APIMessage] {
        messages.map { msg in
            let role = msg.role.rawValue
            if let imageData = msg.imageData, let mediaType = msg.imageMediaType {
                let blocks: [ContentBlock] = [
                    ContentBlock(text: msg.content.isEmpty ? "What do you see in this image?" : msg.content),
                    ContentBlock(imageData: imageData, mediaType: mediaType)
                ]
                return APIMessage(role: role, content: .multipart(blocks))
            } else {
                return APIMessage(role: role, content: .text(msg.content))
            }
        }
    }
}
