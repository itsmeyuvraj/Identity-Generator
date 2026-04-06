import Foundation

// MARK: - Request Bodies

struct AccountRequest: Codable {
    let address: String
    let password: String
}

struct TokenRequest: Codable {
    let address: String
    let password: String
}

// MARK: - Domain

struct DomainsResponse: Codable {
    let members: [Domain]

    enum CodingKeys: String, CodingKey {
        case members = "hydra:member"
    }
}

struct Domain: Codable {
    let id: String
    let domain: String
    let isActive: Bool
    let isPrivate: Bool
}

// MARK: - Account

struct Account: Codable {
    let id: String
    let address: String
}

// MARK: - Token

struct TokenResponse: Codable {
    let token: String
    let id: String
}

// MARK: - Messages

struct MessagesResponse: Codable {
    let members: [Message]

    enum CodingKeys: String, CodingKey {
        case members = "hydra:member"
    }
}

struct Message: Codable, Identifiable, Equatable {
    let id: String
    let from: EmailAddress
    let subject: String
    let intro: String?
    let createdAt: String
    let seen: Bool

    var isRead: Bool { seen }

    enum CodingKeys: String, CodingKey {
        case id, from, subject, intro, createdAt, seen
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.seen == rhs.seen
    }
}

struct EmailAddress: Codable {
    let address: String
    let name: String?
}

// MARK: - Message Detail

struct MessageDetail: Codable, Identifiable {
    let id: String
    let from: EmailAddress
    let subject: String
    let html: [String]?
    let text: String?
    let createdAt: String

    /// Returns the best available body text, HTML tags stripped.
    var bodyText: String {
        if let html = html, !html.isEmpty {
            let joined = html.joined(separator: "\n")
            // Strip HTML tags using regex
            let stripped = joined.replacingOccurrences(
                of: "<[^>]+>",
                with: "",
                options: .regularExpression
            )
            // Collapse whitespace
            let cleaned = stripped
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            return cleaned.isEmpty ? (text ?? "No content.") : cleaned
        }
        return text ?? "No content."
    }
}
