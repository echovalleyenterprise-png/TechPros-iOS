import Foundation

// MARK: - Message

struct ChatMessage: Identifiable, Equatable {
    let id: String
    var role: MessageRole
    var content: String
    var imageData: Data?
    var imageMediaType: String?
    var timestamp: Date
    var isStreaming: Bool = false

    init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        imageData: Data? = nil,
        imageMediaType: String? = nil,
        timestamp: Date = Date(),
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.imageData = imageData
        self.imageMediaType = imageMediaType
        self.timestamp = timestamp
        self.isStreaming = isStreaming
    }

    enum MessageRole: String {
        case user, assistant
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isStreaming == rhs.isStreaming
    }
}

// MARK: - Conversation

struct ConversationListItem: Identifiable, Decodable {
    let id: String
    let title: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - API payload helpers

/// Builds the messages array for the /api/chat request
struct APIMessage: Encodable {
    let role: String
    let content: MessageContent

    enum MessageContent: Encodable {
        case text(String)
        case multipart([ContentBlock])

        func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let str):
                var container = encoder.singleValueContainer()
                try container.encode(str)
            case .multipart(let blocks):
                var container = encoder.singleValueContainer()
                try container.encode(blocks)
            }
        }
    }
}

struct ContentBlock: Encodable {
    let type: String
    let text: String?
    let source: ImageSource?

    init(text: String) {
        self.type = "text"
        self.text = text
        self.source = nil
    }

    init(imageData: Data, mediaType: String) {
        self.type = "image"
        self.text = nil
        self.source = ImageSource(
            type: "base64",
            mediaType: mediaType,
            data: imageData.base64EncodedString()
        )
    }
}

struct ImageSource: Encodable {
    let type: String
    let mediaType: String
    let data: String

    enum CodingKeys: String, CodingKey {
        case type
        case mediaType = "media_type"
        case data
    }
}

// MARK: - API Responses

struct ConversationsResponse: Decodable {
    let conversations: [ConversationListItem]
}

struct ConversationResponse: Decodable {
    let conversation: ConversationItem

    struct ConversationItem: Decodable {
        let id: String
        let title: String?
        let createdAt: Date?
        let updatedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id, title
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }
}

struct MessagesResponse: Decodable {
    let messages: [StoredMessage]

    struct StoredMessage: Decodable {
        let id: String
        let role: String
        let content: String
        let imageUrl: String?
        let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id, role, content
            case imageUrl = "image_url"
            case createdAt = "created_at"
        }
    }
}

struct JobContext {
    var jobType: String = ""
    var brand: String = ""
    var model: String = ""
    var address: String = ""
    var notes: String = ""

    var formatted: String {
        var parts: [String] = []
        if !jobType.isEmpty { parts.append("Job: \(jobType)") }
        if !brand.isEmpty { parts.append("Brand: \(brand)") }
        if !model.isEmpty { parts.append("Model: \(model)") }
        if !address.isEmpty { parts.append("Address: \(address)") }
        if !notes.isEmpty { parts.append("Notes: \(notes)") }
        return parts.joined(separator: " | ")
    }

    var isEmpty: Bool {
        jobType.isEmpty && brand.isEmpty && model.isEmpty && address.isEmpty && notes.isEmpty
    }
}
