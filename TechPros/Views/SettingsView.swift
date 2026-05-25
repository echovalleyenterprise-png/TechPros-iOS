import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                List {
                    // Profile
                    Section {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 52, height: 52)
                                Text(appState.displayName.prefix(1).uppercased())
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(appState.displayName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(appState.currentUser?.email ?? "")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color(red: 0.1, green: 0.1, blue: 0.16))

                    // App info
                    Section("About") {
                        settingsRow(icon: "globe", label: "Website", value: "tech-pros.vercel.app")
                        settingsRow(icon: "app.badge", label: "Version", value: "1.0")
                        settingsRow(icon: "shield.fill", label: "Role", value: appState.userRole.rawValue.capitalized)
                    }
                    .listRowBackground(Color(red: 0.1, green: 0.1, blue: 0.16))

                    // Sign out
                    Section {
                        Button(role: .destructive) {
                            showSignOutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color(red: 0.1, green: 0.1, blue: 0.16))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .alert("Sign Out?", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    dismiss()
                    Task { await appState.signOut() }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
    }

    private func settingsRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.5))
                .font(.subheadline)
        }
    }
}
