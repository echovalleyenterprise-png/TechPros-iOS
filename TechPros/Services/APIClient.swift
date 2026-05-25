import Foundation

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)
    case noToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:       return "Invalid URL"
        case .unauthorized:     return "Session expired. Please sign in again."
        case .serverError(let msg): return msg
        case .decodingError(let e): return "Data error: \(e.localizedDescription)"
        case .networkError(let e):  return e.localizedDescription
        case .noToken:          return "Not authenticated"
        }
    }
}

// MARK: - Client

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let base = Config.apiBaseURL
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            // Try ISO8601 with fractional seconds, then without
            let formatters: [ISO8601DateFormatter] = [
                { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f }(),
                { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f }()
            ]
            for fmt in formatters {
                if let date = fmt.date(from: str) { return date }
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(str)")
        }
        return d
    }()

    // MARK: - Token

    private func token() async throws -> String {
        guard let tok = await AppState.current?.accessToken else { throw APIError.noToken }
        if tok.isEmpty { throw APIError.noToken }
        return tok
    }

    private func headers(token: String) -> [String: String] {
        ["Content-Type": "application/json", "Authorization": "Bearer \(token)"]
    }

    // MARK: - GET

    func get<T: Decodable>(_ path: String) async throws -> T {
        let tok = try await token()
        guard let url = URL(string: base + path) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        headers(token: tok).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        return try await perform(req)
    }

    // MARK: - POST (Codable body)

    func post<T: Decodable>(_ path: String, body: some Encodable) async throws -> T {
        let tok = try await token()
        guard let url = URL(string: base + path) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        headers(token: tok).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = try JSONEncoder().encode(body)
        return try await perform(req)
    }

    // MARK: - POST (raw dict, for legacy usage)

    func postRaw<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        let tok = try await token()
        guard let url = URL(string: base + path) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        headers(token: tok).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await perform(req)
    }

    // MARK: - DELETE

    func delete(_ path: String) async throws {
        let tok = try await token()
        guard let url = URL(string: base + path) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        headers(token: tok).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        _ = try await URLSession.shared.data(for: req)
    }

    // MARK: - Streaming (for /api/chat)

    func stream(_ path: String, body: some Encodable) async throws -> (URLSession.AsyncBytes, URLResponse) {
        let tok = try await token()
        guard let url = URL(string: base + path) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 120
        headers(token: tok).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = try JSONEncoder().encode(body)
        return try await URLSession.shared.bytes(for: req)
    }

    // MARK: - Private

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                if http.statusCode == 401 { throw APIError.unauthorized }
                if http.statusCode >= 400 {
                    if let body = try? JSONDecoder().decode([String: String].self, from: data),
                       let msg = body["error"] ?? body["message"] {
                        throw APIError.serverError(msg)
                    }
                    throw APIError.serverError("Request failed (\(http.statusCode))")
                }
            }
            return try decoder.decode(T.self, from: data)
        } catch let e as APIError { throw e }
        catch let e as DecodingError { throw APIError.decodingError(e) }
        catch { throw APIError.networkError(error) }
    }
}

// MARK: - AppState.current helper

extension AppState {
    /// Non-isolated way to grab the shared instance — set during app init.
    static weak var current: AppState?
}
