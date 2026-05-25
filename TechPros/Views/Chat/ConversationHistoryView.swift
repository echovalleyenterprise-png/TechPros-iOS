import SwiftUI

struct ConversationHistoryView: View {
    @ObservedObject var vm: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                Group {
                    if vm.isLoadingHistory {
                        ProgressView("Loading...")
                            .tint(.blue)
                            .foregroundColor(.white)
                    } else if vm.conversations.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.3))
                            Text("No conversations yet")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    } else {
                        List {
                            ForEach(vm.conversations) { convo in
                                Button {
                                    Task { await vm.loadConversation(convo.id) }
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(convo.title ?? "Untitled conversation")
                                            .foregroundColor(.white)
                                            .font(.subheadline.bold())
                                            .lineLimit(1)
                                        Text(convo.updatedAt, style: .relative)
                                            .foregroundColor(.white.opacity(0.5))
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color(red: 0.1, green: 0.1, blue: 0.16))
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { await vm.deleteConversation(convo.id) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("New Chat") {
                        vm.startNewConversation()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
