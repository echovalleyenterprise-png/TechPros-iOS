import Foundation
import Supabase

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    // MARK: - Sign Up

    struct SignUpResult {
        let requiresEmailConfirmation: Bool
    }

    func signUp(fullName: String, email: String, password: String, role: String = "tech", phone: String = "") async throws -> SignUpResult {
        struct Body: Encodable {
            let fullName, email, password, role, phone: String
            enum CodingKeys: String, CodingKey {
                case fullName = "fullName"
                case email, password, role, phone
            }
        }
        struct Response: Decodable {
            let success: Bool
            let requiresEmailConfirmation: Bool?
            let error: String?
        }
        let resp: Response = try await APIClient.shared.postRaw(
            "/api/auth/signup",
            body: ["fullName": fullName, "email": email, "password": password, "role": role, "phone": phone]
        )
        if let err = resp.error { throw APIError.serverError(err) }
        return SignUpResult(requiresEmailConfirmation: resp.requiresEmailConfirmation ?? true)
    }

    // MARK: - Forgot Password

    func forgotPassword(email: String) async throws {
        // Use the Vercel API route which triggers Supabase reset email
        struct Body: Encodable { let email: String }
        struct Resp: Decodable { let success: Bool?; let error: String? }
        let resp: Resp = try await APIClient.shared.postRaw(
            "/api/auth/forgot-password",
            body: ["email": email]
        )
        if let err = resp.error { throw APIError.serverError(err) }
    }

    // MARK: - Resend Verification

    func resendVerification(email: String) async throws {
        struct Resp: Decodable { let success: Bool?; let error: String? }
        let resp: Resp = try await APIClient.shared.postRaw(
            "/api/auth/resend-verification",
            body: ["email": email]
        )
        if let err = resp.error { throw APIError.serverError(err) }
    }

    // MARK: - Sign Out

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
