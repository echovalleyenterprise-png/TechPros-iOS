import SwiftUI

struct JobContextView: View {
    @Binding var jobContext: JobContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Job Context")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Tell Tech Pros about the job so answers are more specific.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                        Group {
                            contextField(label: "Job Type", icon: "wrench.fill", placeholder: "e.g. TV mount, Ring doorbell", text: $jobContext.jobType)
                            contextField(label: "Brand", icon: "tag.fill", placeholder: "e.g. Samsung, Nest, Ring", text: $jobContext.brand)
                            contextField(label: "Model", icon: "barcode", placeholder: "e.g. QN65S95B, T100", text: $jobContext.model)
                            contextField(label: "Address", icon: "house.fill", placeholder: "Optional — for reference", text: $jobContext.address)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Label("Notes", systemImage: "note.text")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.6))
                            TextEditor(text: $jobContext.notes)
                                .foregroundColor(.white)
                                .tint(.blue)
                                .frame(height: 80)
                                .padding(10)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        }

                        if !jobContext.isEmpty {
                            Button(role: .destructive) {
                                jobContext = JobContext()
                            } label: {
                                Label("Clear Context", systemImage: "trash")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Job Context")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func contextField(label: String, icon: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.6))
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
