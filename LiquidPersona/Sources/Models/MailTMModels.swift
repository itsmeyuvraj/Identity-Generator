import Foundation

// MARK: - Provider

enum EmailProvider: String, CaseIterable, Identifiable {
    case guerrillaMail = "Guerrilla Mail"
    case mailTM        = "Mail.tm"
    case mailinator    = "Mailinator"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .guerrillaMail: return "GML"
        case .mailTM:        return "MTM"
        case .mailinator:    return "MIN"
        }
    }

    var icon: String {
        switch self {
        case .guerrillaMail: return "bolt.fill"
        case .mailTM:        return "envelope.circle.fill"
        case .mailinator:    return "tray.full.fill"
        }
    }

    var description: String {
        switch self {
        case .guerrillaMail: return "Fast & reliable"
        case .mailTM:        return "Registered inbox"
        case .mailinator:    return "Public inbox"
        }
    }

    var accentColor: (r: Double, g: Double, b: Double) {
        switch self {
        case .guerrillaMail: return (0.20, 0.80, 0.45)
        case .mailTM:        return (0.40, 0.55, 1.00)
        case .mailinator:    return (1.00, 0.60, 0.20)
        }
    }
}

// MARK: - Unified Message

struct MailMessage: Identifiable, Equatable {
    let id: String
    let from: String
    let subject: String
    let excerpt: String
    let body: String
    let timestamp: TimeInterval

    static func == (lhs: MailMessage, rhs: MailMessage) -> Bool { lhs.id == rhs.id }
}

// MARK: - Session

struct ProviderSession {
    let email: String
    // Guerrilla Mail
    var sidToken: String?
    // Mail.tm
    var authToken: String?
    // Mailinator
    var mailinatorUser: String?
}
