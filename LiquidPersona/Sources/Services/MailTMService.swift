import Foundation

enum MailServiceError: Error, LocalizedError {
    case sessionFailed
    case networkError(Error)
    case timeout
    case noDomain

    var errorDescription: String? {
        switch self {
        case .sessionFailed:      return "Failed to create email session."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .timeout:            return "Request timed out. Try another service."
        case .noDomain:           return "No email domain available."
        }
    }
}

final class MailTMService {

    static let shared = MailTMService()
    private init() {}

    // MARK: - Create Session

    func createSession(provider: EmailProvider) async throws -> ProviderSession {
        switch provider {
        case .guerrillaMail: return try await guerrillaSession()
        case .mailTM:        return try await mailTMSession()
        case .mailinator:    return try await mailinatorSession()
        }
    }

    // MARK: - Get Messages

    func getMessages(session: ProviderSession, provider: EmailProvider) async throws -> [MailMessage] {
        switch provider {
        case .guerrillaMail: return try await guerrillaMessages(session: session)
        case .mailTM:        return try await mailTMMessages(session: session)
        case .mailinator:    return try await mailinatorMessages(session: session)
        }
    }

    // MARK: - Get Message Detail

    func getMessage(id: String, session: ProviderSession, provider: EmailProvider) async throws -> MailMessage {
        switch provider {
        case .guerrillaMail: return try await guerrillaMessage(id: id, session: session)
        case .mailTM:        return try await mailTMMessage(id: id, session: session)
        case .mailinator:
            // Mailinator includes full body in list — find cached or re-fetch list
            let messages = try await mailinatorMessages(session: session)
            return messages.first(where: { $0.id == id }) ?? MailMessage(
                id: id, from: "", subject: "", excerpt: "", body: "", timestamp: 0)
        }
    }

    // MARK: ── Guerrilla Mail ──────────────────────────────────────────────

    private func guerrillaSession() async throws -> ProviderSession {
        let data = try await get("https://api.guerrillamail.com/ajax.php?f=get_email_address")
        guard
            let json  = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let sid   = json["sid_token"] as? String,
            let email = json["email_addr"] as? String
        else { throw MailServiceError.sessionFailed }
        return ProviderSession(email: email, sidToken: sid)
    }

    private func guerrillaMessages(session: ProviderSession) async throws -> [MailMessage] {
        guard let sid = session.sidToken else { return [] }
        let url = "https://api.guerrillamail.com/ajax.php?f=get_email_list&offset=0&sid_token=\(sid)"
        let data = try await get(url)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let list = json["list"] as? [[String: Any]]
        else { return [] }
        return list.compactMap { parseGuerrillaMsg($0) }
    }

    private func guerrillaMessage(id: String, session: ProviderSession) async throws -> MailMessage {
        guard let sid = session.sidToken else { throw MailServiceError.sessionFailed }
        let url = "https://api.guerrillamail.com/ajax.php?f=fetch_email&email_id=\(id)&sid_token=\(sid)"
        let data = try await get(url)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let msg  = parseGuerrillaMsg(json)
        else { throw MailServiceError.sessionFailed }
        return msg
    }

    private func parseGuerrillaMsg(_ d: [String: Any]) -> MailMessage? {
        guard let rawId = d["mail_id"] else { return nil }
        let id = rawId as? String ?? String(rawId as? Int ?? 0)
        let from    = d["mail_from"]      as? String ?? ""
        let subject = d["mail_subject"]   as? String ?? "(no subject)"
        let excerpt = d["mail_excerpt"]   as? String ?? ""
        let body    = d["mail_body"]      as? String ?? excerpt
        let ts      = d["mail_timestamp"] as? TimeInterval ?? 0
        return MailMessage(id: id, from: from, subject: subject, excerpt: excerpt, body: body, timestamp: ts)
    }

    // MARK: ── Mail.tm ────────────────────────────────────────────────────

    private func mailTMSession() async throws -> ProviderSession {
        // 1. Get domain
        let domainData = try await get("https://api.mail.tm/domains")
        guard
            let json    = try? JSONSerialization.jsonObject(with: domainData) as? [String: Any],
            let members = json["hydra:member"] as? [[String: Any]],
            let domain  = members.first(where: {
                ($0["isActive"] as? Bool == true) && ($0["isPrivate"] as? Bool == false)
            })?["domain"] as? String
        else { throw MailServiceError.noDomain }

        // 2. Create account
        let tag      = Int.random(in: 1000...9999)
        let user     = "user\(tag)"
        let email    = "\(user)@\(domain)"
        let password = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12)) + "Aa1!"

        let accountBody: [String: String] = ["address": email, "password": password]
        let accountData = try JSONSerialization.data(withJSONObject: accountBody)
        _ = try await post("https://api.mail.tm/accounts", body: accountData)

        // 3. Get token
        let tokenBody: [String: String] = ["address": email, "password": password]
        let tokenBodyData = try JSONSerialization.data(withJSONObject: tokenBody)
        let tokenData = try await post("https://api.mail.tm/token", body: tokenBodyData)
        guard
            let tokenJson = try? JSONSerialization.jsonObject(with: tokenData) as? [String: Any],
            let token     = tokenJson["token"] as? String
        else { throw MailServiceError.sessionFailed }

        return ProviderSession(email: email, authToken: token)
    }

    private func mailTMMessages(session: ProviderSession) async throws -> [MailMessage] {
        guard let token = session.authToken else { return [] }
        let data = try await get("https://api.mail.tm/messages", bearer: token)
        guard
            let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let members = json["hydra:member"] as? [[String: Any]]
        else { return [] }
        return members.compactMap { parseMailTMMsg($0) }
    }

    private func mailTMMessage(id: String, session: ProviderSession) async throws -> MailMessage {
        guard let token = session.authToken else { throw MailServiceError.sessionFailed }
        let data = try await get("https://api.mail.tm/messages/\(id)", bearer: token)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let msg  = parseMailTMMsg(json)
        else { throw MailServiceError.sessionFailed }
        return msg
    }

    private func parseMailTMMsg(_ d: [String: Any]) -> MailMessage? {
        guard let id = d["id"] as? String else { return nil }
        let fromObj = d["from"] as? [String: Any]
        let from    = fromObj?["address"] as? String ?? ""
        let subject = d["subject"] as? String ?? "(no subject)"
        let intro   = d["intro"] as? String ?? ""
        let html    = (d["html"] as? [String] ?? []).joined()
        let text    = d["text"] as? String ?? intro
        let body    = html.isEmpty ? text : stripHTML(html)
        let created = d["createdAt"] as? String ?? ""
        let ts      = isoToTimestamp(created)
        return MailMessage(id: id, from: from, subject: subject, excerpt: intro, body: body, timestamp: ts)
    }

    // MARK: ── Mailinator ─────────────────────────────────────────────────

    private func mailinatorSession() async throws -> ProviderSession {
        let chars   = "abcdefghijklmnopqrstuvwxyz"
        let user    = String((0..<10).map { _ in chars.randomElement()! })
        let email   = "\(user)@mailinator.com"
        return ProviderSession(email: email, mailinatorUser: user)
    }

    private func mailinatorMessages(session: ProviderSession) async throws -> [MailMessage] {
        guard let user = session.mailinatorUser else { return [] }
        let url  = "https://www.mailinator.com/api/v2/domains/public/inboxes/\(user)"
        let data = try await get(url)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let msgs = json["msgs"] as? [[String: Any]]
        else { return [] }
        return msgs.compactMap { parseMailinatorMsg($0) }
    }

    private func parseMailinatorMsg(_ d: [String: Any]) -> MailMessage? {
        guard let id = d["id"] as? String else { return nil }
        let from    = d["fromfull"] as? String ?? d["from"] as? String ?? ""
        let subject = d["subject"] as? String ?? "(no subject)"
        let body    = d["mail_body"] as? String ?? d["body"] as? String ?? ""
        let excerpt = String(body.prefix(120))
        let ts      = (d["time"] as? Double ?? 0) / 1000.0
        return MailMessage(id: id, from: from, subject: subject, excerpt: excerpt, body: body, timestamp: ts)
    }

    // MARK: ── HTTP Helpers ───────────────────────────────────────────────

    private func get(_ urlStr: String, bearer: String? = nil) async throws -> Data {
        guard let url = URL(string: urlStr) else { throw MailServiceError.sessionFailed }
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        if let bearer { req.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization") }
        return try await fetch(req)
    }

    private func post(_ urlStr: String, body: Data) async throws -> Data {
        guard let url = URL(string: urlStr) else { throw MailServiceError.sessionFailed }
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        req.httpBody = body
        return try await fetch(req)
    }

    private func fetch(_ req: URLRequest) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            return data
        } catch let e as URLError where e.code == .timedOut {
            throw MailServiceError.timeout
        } catch {
            throw MailServiceError.networkError(error)
        }
    }

    // MARK: ── Utilities ──────────────────────────────────────────────────

    private func stripHTML(_ html: String) -> String {
        let stripped = html.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        return stripped.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.joined(separator: " ")
    }

    private func isoToTimestamp(_ iso: String) -> TimeInterval {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: iso)?.timeIntervalSince1970 ?? 0
    }
}
