import SwiftUI

enum AuthScreen {
    case login, signup, forgotPassword
}

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Navigation
    @Published var screen: AuthScreen = .login

    // MARK: - Login
    @Published var loginEmail = ""
    @Published var loginPassword = ""

    // MARK: - Sign Up (4-step)
    @Published var signupStep = 1
    @Published var signupFullName = ""
    @Published var signupEmail = ""
    @Published var signupPassword = ""
    @Published var signupConfirmPassword = ""
    @Published var signupPhone = ""
    @Published var signupRole = "tech"
    @Published var signupComplete = false      // → show "check your email" screen

    // MARK: - Forgot Password
    @Published var forgotEmail = ""
    @Published var forgotSent = false

    // MARK: - Shared state
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showEmailNotConfirmed = false

    // MARK: - Login

    func login() async {
        guard !loginEmail.isEmpty, !loginPassword.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.signIn(email: loginEmail, password: loginPassword)
            // AppState listener will update isAuthenticated
        } catch {
            if error.localizedDescription.lowercased().contains("email not confirmed") ||
               error.localizedDescription.lowercased().contains("not confirmed") {
                showEmailNotConfirmed = true
            } else {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }

    // MARK: - Sign Up

    func nextSignupStep() {
        errorMessage = nil
        switch signupStep {
        case 1:
            guard !signupFullName.isEmpty else { errorMessage = "Please enter your name."; return }
            signupStep = 2
        case 2:
            guard signupEmail.contains("@") else { errorMessage = "Please enter a valid email."; return }
            signupStep = 3
        case 3:
            guard signupPassword.count >= 8 else { errorMessage = "Password must be at least 8 characters."; return }
            guard signupPassword == signupConfirmPassword else { errorMessage = "Passwords don't match."; return }
            signupStep = 4
        case 4:
            Task { await submitSignup() }
        default: break
        }
    }

    private func submitSignup() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthService.shared.signUp(
                fullName: signupFullName,
                email: signupEmail,
                password: signupPassword,
                role: signupRole,
                phone: signupPhone
            )
            signupComplete = result.requiresEmailConfirmation
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Forgot Password

    func sendPasswordReset() async {
        guard forgotEmail.contains("@") else { errorMessage = "Please enter a valid email."; return }
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.forgotPassword(email: forgotEmail)
            forgotSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers

    func resetErrors() { errorMessage = nil }

    func resendVerification() async {
        guard !loginEmail.isEmpty else { return }
        try? await AuthService.shared.resendVerification(email: loginEmail)
    }
}
