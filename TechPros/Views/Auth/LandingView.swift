import SwiftUI

struct LandingView: View {
    @StateObject private var vm = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        Text("Tech Pros")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                        Text("AI field support for installation techs")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: 14) {
                        NavigationLink {
                            LoginView(vm: vm)
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(14)
                        }

                        NavigationLink {
                            SignUpView(vm: vm)
                        } label: {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 50)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
