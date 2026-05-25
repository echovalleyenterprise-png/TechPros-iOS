import SwiftUI
import PhotosUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ChatViewModel()
    @State private var showSettings = false
    @State private var showReference = false
    @State private var showEscalateConfirm = false
    @State private var escalateSent = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Messages
                    messageList

                    // Input bar
                    inputBar
                }
            }
            .navigationTitle("Tech Pros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task { await vm.loadConversations() }
                        vm.showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        vm.startNewConversation()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                    }
                    Menu {
                        Button { showReference = true } label: {
                            Label("Reference Guide", systemImage: "book.fill")
                        }
                        Button { vm.showJobContext = true } label: {
                            Label("Job Context", systemImage: "briefcase.fill")
                        }
                        Toggle(isOn: $vm.customerSafeMode) {
                            Label("Customer-Safe Mode", systemImage: "person.fill.checkmark")
                        }
                        Toggle(isOn: Binding(
                            get: { vm.language == "es" },
                            set: { vm.language = $0 ? "es" : "en" }
                        )) {
                            Label("Spanish", systemImage: "globe")
                        }
                        Divider()
                        Button(role: .destructive) { showEscalateConfirm = true } label: {
                            Label("Escalate to Lead", systemImage: "exclamationmark.triangle.fill")
                        }
                        Divider()
                        Button { showSettings = true } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            // Sheets
            .sheet(isPresented: $vm.showHistory) {
                ConversationHistoryView(vm: vm)
            }
            .sheet(isPresented: $vm.showJobContext) {
                JobContextView(jobContext: $vm.jobContext)
            }
            .sheet(isPresented: $vm.showSOPSave) {
                SOPSaveView(content: vm.sopContent)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showReference) {
                ReferenceGuideView()
            }
            // Alerts
            .alert("Escalate to Lead?", isPresented: $showEscalateConfirm) {
                Button("Escalate", role: .destructive) {
                    Task {
                        await vm.escalate()
                        escalateSent = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will send the current conversation to your lead via Slack.")
            }
            .alert("Escalation Sent", isPresented: $escalateSent) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your lead has been notified.")
            }
        }
        .onChange(of: vm.selectedPhotoItem) { _, _ in
            Task { await vm.loadSelectedPhoto() }
        }
        .task {
            // Wire up AppState reference for APIClient
            AppState.current = appState
        }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Empty state / quick actions
                    if vm.messages.isEmpty {
                        emptyState
                    }

                    // Messages
                    ForEach(vm.messages) { message in
                        MessageBubbleView(
                            message: message,
                            onThumbsUp: {
                                Task { await vm.submitFeedback(messageId: message.id, rating: 1) }
                            },
                            onThumbsDown: {
                                Task { await vm.submitFeedback(messageId: message.id, rating: -1) }
                            },
                            onSaveSOP: {
                                vm.sopContent = message.content
                                vm.showSOPSave = true
                            }
                        )
                        .id(message.id)
                    }
                }
                .padding(.bottom, 8)
            }
            .onChange(of: vm.messages.count) { _, _ in
                if let last = vm.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: vm.messages.last?.content) { _, _ in
                if let last = vm.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("What do you need help with?")
                    .font(.headline)
                    .foregroundColor(.white)
                if !vm.jobContext.isEmpty {
                    Text(vm.jobContext.formatted)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 40)

            QuickActionsView(actions: vm.quickActions) { prompt in
                Task { await vm.sendQuickAction(prompt) }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))

            // Pending image preview
            if let imageData = vm.pendingImageData, let uiImage = UIImage(data: imageData) {
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .cornerRadius(10)
                        .clipped()
                    Spacer()
                    Button {
                        vm.pendingImageData = nil
                        vm.selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }

            HStack(spacing: 10) {
                // Photo picker
                PhotosPicker(selection: $vm.selectedPhotoItem, matching: .images) {
                    Image(systemName: "photo")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 36, height: 36)
                }

                // Voice input
                VoiceInputButton(text: $vm.inputText)

                // Text field
                TextField("Ask anything...", text: $vm.inputText, axis: .vertical)
                    .foregroundColor(.white)
                    .tint(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(20)
                    .lineLimit(1...5)

                // Send button
                Button {
                    hideKeyboard()
                    Task { await vm.sendMessage() }
                } label: {
                    Image(systemName: vm.isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            (vm.inputText.isEmpty && vm.pendingImageData == nil && !vm.isStreaming)
                                ? AnyShapeStyle(Color.white.opacity(0.3))
                                : AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                }
                .disabled(vm.inputText.isEmpty && vm.pendingImageData == nil && !vm.isStreaming)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    }
}
