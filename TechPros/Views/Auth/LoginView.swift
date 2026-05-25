import SwiftUI

struct LoginView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text("Welcome back")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Sign in to Tech Pros")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 24)

                    // Form
                    VStack(spacing: 14) {
                        AuthTextField(icon: "envelope", placeholder: "Email", text: $vm.loginEmail, keyboardType: .emailAddress)
                        AuthTextField(icon: "lock", placeholder: "Password", text: $vm.loginPassword, isSecure: true)
                    }

                    // Error
                    if let err = vm.errorMessage {
                        ErrorBanner(message: err)
                    }

                    // Email not confirmed
                    if vm.showEmailNotConfirmed {
                        VStack(spacing: 8) {
                            Text("Email not confirmed")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Text("Check your inbox for a verification link.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                            Button("Resend email") {
                                Task { await vm.resendVerification() }
                            }
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Sign In button
                    Button {
                        Task { await vm.login() }
                    } label: {
                        Group {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                    }
                    .disabled(vm.isLoading)

                    // Forgot password
                    NavigationLink {
                        ForgotPasswordView(vm: vm)
                    } label: {
                        Text("Forgot password?")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onTapGesture { hideKeyboard() }
    }
}

// MARK: - Helpers

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.blue)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.blue)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }
}

struct ErrorBanner: View {
    let message: String
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
