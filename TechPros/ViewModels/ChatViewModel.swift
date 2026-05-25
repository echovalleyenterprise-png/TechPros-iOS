import SwiftUI
import PhotosUI

@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: - Messages
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isStreaming = false
    @Published var errorMessage: String?

    // MARK: - Image
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingImageData: Data?
    @Published var pendingImageMediaType: String = "image/jpeg"

    // MARK: - Conversation
    @Published var conversationId: String?
    @Published var conversations: [ConversationListItem] = []
    @Published var showHistory = false
    @Published var isLoadingHistory = false

    // MARK: - Modals
    @Published var showJobContext = false
    @Published var showSOPSave = false
    @Published var sopContent = ""
    @Published var jobContext = JobContext()

    // MARK: - Settings
    @Published var customerSafeMode = false
    @Published var language: String = "en"
    @Published var mode: String = "tech"

    // MARK: - Feedback
    @Published var feedbackMessageId: String?
    @Published var showFeedbackConfirm = false

    // MARK: - Streaming cursor
    private var streamingMessageId: String?

    // MARK: - Quick actions
    let quickActions: [(title: String, prompt: String)] = [
        ("📺 TV Won't Turn On",    "The TV won't power on. How do I troubleshoot it?"),
        ("📡 No Signal",           "Getting 'No Signal' on the TV. What are the steps?"),
        ("🔊 No Audio",            "Picture is fine but no sound from the soundbar. How do I fix this?"),
        ("📶 WiFi Won't Connect",  "The device won't connect to WiFi. Walk me through the troubleshooting steps."),
        ("🔔 Doorbell Not Ringing","The Ring doorbell isn't ringing inside the house. How do I fix this?"),
        ("🌡️ Thermostat Blank",    "The Nest thermostat has a blank screen. What are the wiring checks?"),
        ("📷 Camera Offline",      "The security camera is showing offline in the app. How do I get it back online?"),
        ("🔧 Factory Reset",       "How do I factory reset this device?")
    ]

    // MARK: - Send message

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let image = pendingImageData
        let mediaType = pendingImageMediaType

        guard !text.isEmpty || image != nil else { return }

        // Build user message
        let userMessage = ChatMessage(
            role: .user,
            content: text,
            imageData: image,
            imageMediaType: image != nil ? mediaType : nil
        )
        messages.append(userMessage)
        inputText = ""
        pendingImageData = nil
        selectedPhotoItem = nil

        // Ensure conversation exists
        if conversationId == nil {
            do {
                conversationId = try await ConversationService.shared.createConversation(
                    title: text.isEmpty ? "Photo question" : String(text.prefix(50))
                )
            } catch {
                // Non-fatal — chat still works, just won't be persisted
                conversationId = UUID().uuidString
            }
        }

        // Start streaming placeholder
        let assistantId = UUID().uuidString
        streamingMessageId = assistantId
        var streamingMsg = ChatMessage(id: assistantId, role: .assistant, content: "", isStreaming: true)
        messages.append(streamingMsg)
        isStreaming = true
        errorMessage = nil

        do {
            let stream = try await ChatService.shared.streamChat(
                messages: messages.filter { $0.id != assistantId }, // exclude placeholder
                conversationId: conversationId,
                customerSafeMode: customerSafeMode,
                language: language,
                mode: mode
            )
            for try await chunk in stream {
                if let idx = messages.firstIndex(where: { $0.id == assistantId }) {
                    messages[idx].content += chunk
                }
            }
        } catch {
            if let idx = messages.firstIndex(where: { $0.id == assistantId }) {
                messages[idx].content = "Something went wrong. Please try again."
            }
            errorMessage = error.localizedDescription
        }

        // Finalize streaming message
        if let idx = messages.firstIndex(where: { $0.id == assistantId }) {
            messages[idx].isStreaming = false
            sopContent = messages[idx].content
        }
        isStreaming = false
        streamingMessageId = nil
    }

    func sendQuickAction(_ prompt: String) async {
        inputText = prompt
        await sendMessage()
    }

    // MARK: - Image handling

    func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            pendingImageData = data
            pendingImageMediaType = "image/jpeg"
        }
    }

    // MARK: - Feedback

    func submitFeedback(messageId: String, rating: Int) async {
        try? await ChatService.shared.submitFeedback(messageId: messageId, rating: rating)
    }

    // MARK: - Escalation

    func escalate() async {
        do {
            try await ChatService.shared.escalate(
                messages: messages,
                jobContext: jobContext.isEmpty ? nil : jobContext.formatted,
                conversationId: conversationId
            )
        } catch {
            errorMessage = "Failed to escalate: \(error.localizedDescription)"
        }
    }

    // MARK: - Conversation history

    func loadConversations() async {
        isLoadingHistory = true
        do {
            conversations = try await ConversationService.shared.listConversations()
        } catch { /* fail silently */ }
        isLoadingHistory = false
    }

    func loadConversation(_ id: String) async {
        do {
            let loaded = try await ConversationService.shared.loadMessages(conversationId: id)
            conversationId = id
            messages = loaded
            showHistory = false
        } catch {
            errorMessage = "Failed to load conversation."
        }
    }

    func deleteConversation(_ id: String) async {
        try? await ConversationService.shared.deleteConversation(id: id)
        conversations.removeAll { $0.id == id }
        if conversationId == id { startNewConversation() }
    }

    func startNewConversation() {
        messages = []
        conversationId = nil
        inputText = ""
        pendingImageData = nil
        jobContext = JobContext()
        showHistory = false
    }

    // MARK: - Last assistant message (for SOP save)

    var lastAssistantMessage: String {
        messages.last(where: { $0.role == .assistant })?.content ?? ""
    }
}
