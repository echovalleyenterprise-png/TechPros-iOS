import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                if vm.forgotSent {
                    // Success
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Email sent!")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Check your inbox for a password reset link.")
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Button("Back to Sign In") { dismiss() }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))

                        VStack(spacing: 8) {
                            Text("Forgot password?")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            Text("Enter your email and we'll send you a reset link.")
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }

                        AuthTextField(icon: "envelope", placeholder: "Email address", text: $vm.forgotEmail, keyboardType: .emailAddress)

                        if let err = vm.errorMessage {
                            ErrorBanner(message: err)
                        }

                        Button {
                            Task { await vm.sendPasswordReset() }
                        } label: {
                            Group {
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Send Reset Link")
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
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onTapGesture { hideKeyboard() }
    }
}
