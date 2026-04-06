import Foundation

// MARK: - Errors

enum MailTMError: Error, LocalizedError {
    case noDomainAvailable
    case accountCreationFailed(Int, String)
    case tokenFailed(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .noDomainAvailable:
            return "No active email domain available right now."
        case .accountCreationFailed(let code, let msg):
            return "Account creation failed (\(code)): \(msg)"
        case .tokenFailed(let code):
            return "Authentication failed (HTTP \(code))."
        case .networkError(let err):
            return "Network error: \(err.localizedDescription)"
        }
    }
}

// MARK: - Service

final class MailTMService {

    static let shared = MailTMService()

    private init() {}

    // MARK: Domains

    func getActiveDomain() async throws -> String {
        let (data, _) = try await get(path: "/domains")
        let response = try decode(DomainsResponse.self, from: data)
        guard let domain = response.members.first(where: { $0.isActive && !$0.isPrivate }) else {
            throw MailTMError.noDomainAvailable
        }
        return domain.domain
    }

    // MARK: Account

    func createAccount(address: String, password: String) async throws -> Account {
        let body = AccountRequest(address: address, password: password)
        let (data, resp) = try await post(path: "/accounts", body: body)
        let status = (resp as! HTTPURLResponse).statusCode
        guard status == 201 else {
            let msg = String(data: data, encoding: .utf8) ?? ""
            throw MailTMError.accountCreationFailed(status, msg)
        }
        return try decode(Account.self, from: data)
    }

    // MARK: Token

    func getToken(address: String, password: String) async throws -> String {
        let body = TokenRequest(address: address, password: password)
        let (data, resp) = try await post(path: "/token", body: body)
        let status = (resp as! HTTPURLResponse).statusCode
        guard status == 200 else {
            throw MailTMError.tokenFailed(status)
        }
        let tokenResp = try decode(TokenResponse.self, from: data)
        return tokenResp.token
    }

    // MARK: Messages

    func getMessages(token: String) async throws -> [Message] {
        let (data, _) = try await get(path: "/messages", token: token)
        let response = try decode(MessagesResponse.self, from: data)
        return response.members
    }

    func getMessage(id: String, token: String) async throws -> MessageDetail {
        let (data, _) = try await get(path: "/messages/\(id)", token: token)
        return try decode(MessageDetail.self, from: data)
    }

    // MARK: - Private Helpers

    private func url(_ path: String) -> URL {
        URL(string: "https://api.mail.tm" + path)!
    }

    private func get(path: String, token: String? = nil) async throws -> (Data, URLResponse) {
        var req = URLRequest(url: url(path), timeoutInterval: 15)
        req.httpMethod = "GET"
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            return try await URLSession.shared.data(for: req)
        } catch {
            throw MailTMError.networkError(error)
        }
    }

    private func post<T: Encodable>(path: String, body: T) async throws -> (Data, URLResponse) {
        var req = URLRequest(url: url(path), timeoutInterval: 15)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        do {
            return try await URLSession.shared.data(for: req)
        } catch {
            throw MailTMError.networkError(error)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}
