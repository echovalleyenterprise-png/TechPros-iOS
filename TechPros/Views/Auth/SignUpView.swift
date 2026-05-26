import SwiftUI

struct SignUpView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

            if vm.signupComplete {
                // Check email screen
                checkEmailView
            } else {
                signupFormView
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onTapGesture { hideKeyboard() }
    }

    // MARK: - Steps

    private var signupFormView: some View {
        VStack(spacing: 0) {
            // Step indicator
            StepIndicator(current: vm.signupStep, total: 4)
                .padding(.top, 20)
                .padding(.horizontal, 28)

            ScrollView {
                VStack(spacing: 24) {
                    // Step content
                    switch vm.signupStep {
                    case 1: step1
                    case 2: step2
                    case 3: step3
                    case 4: step4
                    default: EmptyView()
                    }

                    // Error
                    if let err = vm.errorMessage {
                        ErrorBanner(message: err)
                    }

                    // Continue button
                    Button {
                        vm.nextSignupStep()
                    } label: {
                        Group {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(vm.signupStep == 4 ? "Create Account" : "Continue")
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

                    // Back
                    if vm.signupStep > 1 {
                        Button("← Back") { vm.signupStep -= 1; vm.errorMessage = nil }
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Individual steps

    private var step1: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepHeader(icon: "person.fill", title: "What's your name?", subtitle: "We'll use this to personalize your experience")
            AuthTextField(icon: "person", placeholder: "Full name", text: $vm.signupFullName)
        }
    }

    private var step2: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepHeader(icon: "envelope.fill", title: "Your email", subtitle: "We'll send a verification link here")
            AuthTextField(icon: "envelope", placeholder: "Email address", text: $vm.signupEmail, keyboardType: .emailAddress)
        }
    }

    private var step3: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepHeader(icon: "lock.fill", title: "Create a password", subtitle: "Minimum 8 characters")
            AuthTextField(icon: "lock", placeholder: "Password", text: $vm.signupPassword, isSecure: true)
            AuthTextField(icon: "lock.rotation", placeholder: "Confirm password", text: $vm.signupConfirmPassword, isSecure: true)
        }
    }

    private var step4: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepHeader(icon: "phone.fill", title: "Your phone number", subtitle: "Optional — for account recovery")
            AuthTextField(icon: "phone", placeholder: "Phone number (optional)", text: $vm.signupPhone, keyboardType: .phonePad)
        }
    }

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Check email

    private var checkEmailView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 8) {
                Text("Check your email")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("We sent a verification link to\n\(vm.signupEmail)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            Button("Back to Sign In") { dismiss() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(14)
                .padding(.horizontal, 28)
            Spacer()
        }
    }
}

// MARK: - Step indicator

struct StepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? Color.blue : Color.white.opacity(0.2))
                    .frame(height: 4)
                    .animation(.easeInOut, value: current)
            }
        }
    }
}
