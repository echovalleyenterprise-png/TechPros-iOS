import SwiftUI

struct SOPSaveView: View {
    let content: String
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var brand = "general"
    @State private var model = ""
    @State private var deviceType = "general"
    @State private var isSaving = false
    @State private var saved = false
    @State private var errorMessage: String?

    let deviceTypes = ["general", "tv", "soundbar", "security_camera", "thermostat", "networking", "smart_speaker", "doorbell"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                if saved {
                    savedView
                } else {
                    formView
                }
            }
            .navigationTitle("Save as SOP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !saved {
                        Button("Save") { Task { await save() } }
                            .bold()
                            .foregroundColor(.blue)
                            .disabled(title.isEmpty || isSaving)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Save this answer to the knowledge base so Tech Pros can reference it in future jobs.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Content preview
                VStack(alignment: .leading, spacing: 6) {
                    Text("CONTENT PREVIEW")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.4))
                    Text(content.prefix(200) + (content.count > 200 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                }

                sopField(label: "Title *", placeholder: "e.g. Ring Doorbell Offline Fix", text: $title)
                sopField(label: "Brand", placeholder: "e.g. Ring, Nest, Samsung", text: $brand)
                sopField(label: "Model", placeholder: "Optional", text: $model)

                VStack(alignment: .leading, spacing: 6) {
                    Text("DEVICE TYPE")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.4))
                    Picker("Device Type", selection: $deviceType) {
                        ForEach(deviceTypes, id: \.self) { type in
                            Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }

                if let err = errorMessage {
                    ErrorBanner(message: err)
                }
            }
            .padding(20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Saved

    private var savedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("Saved to Knowledge Base")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Tech Pros will reference this in future troubleshooting.")
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Done") { dismiss() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .cornerRadius(14)
                .padding(.horizontal, 28)
            Spacer()
        }
    }

    // MARK: - Save action

    private func save() async {
        isSaving = true
        errorMessage = nil
        do {
            try await ChatService.shared.saveSOP(
                title: title,
                content: content,
                brand: brand.isEmpty ? "general" : brand,
                model: model,
                deviceType: deviceType
            )
            saved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    private func sopField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.4))
            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .tint(.blue)
                .padding()
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }
}
