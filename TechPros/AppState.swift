import SwiftUI
import Supabase

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true
    @Published var userRole: UserRole = .tech

    private var authListenerTask: Task<Void, Never>?

    init() {
        startAuthListener()
    }

    deinit {
        authListenerTask?.cancel()
    }

    // MARK: - Auth listener

    private func startAuthListener() {
        authListenerTask = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    switch event {
                    case .initialSession, .signedIn, .tokenRefreshed:
                        self.isAuthenticated = session != nil
                        self.currentUser = session?.user
                        self.userRole = self.extractRole(from: session?.user)
                        self.isLoading = false
                    case .signedOut:
                        self.isAuthenticated = false
                        self.currentUser = nil
                        self.userRole = .tech
                        self.isLoading = false
                    default:
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func extractRole(from user: User?) -> UserRole {
        guard let user else { return .tech }
        if case .string(let role) = user.userMetadata["role"] {
            return UserRole(rawValue: role) ?? .tech
        }
        return .tech
    }

    var displayName: String {
        if let user = currentUser {
            if case .string(let name) = user.userMetadata["full_name"], !name.isEmpty {
                return name
            }
            return user.email ?? "Tech"
        }
        return "Tech"
    }

    var isAdmin: Bool { userRole == .admin }

    // MARK: - Sign out

    func signOut() async {
        try? await supabase.auth.signOut()
    }

    // MARK: - Access token for API calls

    var accessToken: String? {
        get async {
            return try? await supabase.auth.session.accessToken
        }
    }
}

// MARK: - User role

enum UserRole: String {
    case tech, admin, customer
}
