import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    var onThumbsUp: (() -> Void)?
    var onThumbsDown: (() -> Void)?
    var onSaveSOP: (() -> Void)?

    @State private var copied = false
    @State private var feedbackGiven: Int? = nil

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                // Image attachment
                if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 220)
                        .cornerRadius(14)
                }

                // Bubble
                VStack(alignment: .leading, spacing: 0) {
                    if message.isStreaming && message.content.isEmpty {
                        typingIndicator
                    } else if !message.content.isEmpty {
                        Text(message.content)
                            .foregroundColor(.white)
                            .font(.body)
                            .textSelection(.enabled)
                    }

                    // Streaming cursor
                    if message.isStreaming && !message.content.isEmpty {
                        Text("▋")
                            .foregroundColor(.blue)
                            .font(.body)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser
                    ? AnyShapeStyle(LinearGradient(colors: [.blue, Color(red: 0, green: 0.6, blue: 1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color(red: 0.15, green: 0.15, blue: 0.22))
                )
                .cornerRadius(18, corners: isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])

                // Action row (assistant messages only)
                if !isUser && !message.isStreaming && !message.content.isEmpty {
                    actionRow
                }
            }

            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - Typing indicator

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 7, height: 7)
                    .offset(y: 0)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15),
                        value: message.isStreaming
                    )
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Action row

    private var actionRow: some View {
        HStack(spacing: 14) {
            // Copy
            Button {
                UIPasteboard.general.string = message.content
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(copied ? .green : .white.opacity(0.5))
            }

            // Thumbs up
            Button {
                guard feedbackGiven == nil else { return }
                feedbackGiven = 1
                onThumbsUp?()
            } label: {
                Image(systemName: feedbackGiven == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.caption)
                    .foregroundColor(feedbackGiven == 1 ? .green : .white.opacity(0.5))
            }

            // Thumbs down
            Button {
                guard feedbackGiven == nil else { return }
                feedbackGiven = -1
                onThumbsDown?()
            } label: {
                Image(systemName: feedbackGiven == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.caption)
                    .foregroundColor(feedbackGiven == -1 ? .red : .white.opacity(0.5))
            }

            // Save as SOP
            Button {
                onSaveSOP?()
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Rounded corners helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
