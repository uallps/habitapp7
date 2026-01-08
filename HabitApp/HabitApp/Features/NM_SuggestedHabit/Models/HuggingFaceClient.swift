import Foundation

enum HuggingFaceError: LocalizedError {
    case missingToken
    case invalidResponse
    case server(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "Missing Hugging Face API token."
        case .invalidResponse:
            return "Invalid response from Hugging Face API."
        case .server(let message):
            return message
        case .decodingFailed:
            return "Failed to decode Hugging Face response."
        }
    }
}

struct HuggingFaceConfig {
    nonisolated static let userDefaultsTokenKey = "huggingFaceApiToken"
    nonisolated static let infoPlistTokenKey = "HUGGINGFACE_API_TOKEN"
    nonisolated static let defaultModelId = "mistralai/Mistral-7B-Instruct-v0.2"

    nonisolated static func resolveApiToken() -> String? {
        if let token = Bundle.main.object(forInfoDictionaryKey: infoPlistTokenKey) as? String {
            let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        if let stored = UserDefaults.standard.string(forKey: userDefaultsTokenKey) {
            let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        return nil
    }
}

struct HuggingFaceClient {
    private let modelId: String
    private let apiToken: String
    private let session: URLSession

    init(
        modelId: String = HuggingFaceConfig.defaultModelId,
        apiToken: String? = HuggingFaceConfig.resolveApiToken(),
        session: URLSession = .shared
    ) throws {
        guard let apiToken, !apiToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw HuggingFaceError.missingToken
        }

        self.modelId = modelId
        self.apiToken = apiToken
        self.session = session
    }

    func generateHabitSuggestions(count: Int, focus: String?) async throws -> [SuggestedHabitDraft] {
        let prompt = buildPrompt(count: count, focus: focus)
        let requestBody = HFRequest(
            inputs: prompt,
            parameters: HFParameters(
                maxNewTokens: 320,
                temperature: 0.7,
                returnFullText: false
            ),
            options: HFOptions(waitForModel: true, useCache: true)
        )

        var request = URLRequest(url: modelURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HuggingFaceError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            if let error = decodeServerError(from: data) {
                throw HuggingFaceError.server(error)
            }

            if let body = decodeBodyText(from: data) {
                throw HuggingFaceError.server("HTTP \(httpResponse.statusCode): \(body)")
            }

            throw HuggingFaceError.server("HTTP \(httpResponse.statusCode)")
        }

        if let generated = try? JSONDecoder().decode([HFGeneratedText].self, from: data),
           let text = generated.first?.generated_text {
            return parseGeneratedText(text, expectedCount: count)
        }

        if let single = try? JSONDecoder().decode(HFGeneratedText.self, from: data) {
            return parseGeneratedText(single.generated_text, expectedCount: count)
        }

        if let error = decodeServerError(from: data) {
            throw HuggingFaceError.server(error)
        }

        if let body = decodeBodyText(from: data) {
            throw HuggingFaceError.server("Unexpected response: \(body)")
        }

        throw HuggingFaceError.decodingFailed
    }

    private func modelURL() -> URL {
        URL(string: "https://router.huggingface.co/hf-inference/models/\(modelId)")!
    }

    private func buildPrompt(count: Int, focus: String?) -> String {
        var prompt = "You are a habit coach. Generate \(count) habit suggestions in Spanish. "
        prompt += "Return ONLY a JSON array of objects with keys \"title\" and \"details\". "
        prompt += "Keep titles short and practical."

        if let focus, !focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            prompt += " Focus on: \(focus)."
        }

        return prompt
    }

    private func parseGeneratedText(_ text: String, expectedCount: Int) -> [SuggestedHabitDraft] {
        if let jsonItems = decodeJSONItems(from: text) {
            return trim(items: jsonItems, expectedCount: expectedCount)
        }

        let fallbackItems = parseLines(from: text)
        return trim(items: fallbackItems, expectedCount: expectedCount)
    }

    private func decodeJSONItems(from text: String) -> [SuggestedHabitDraft]? {
        guard let start = text.firstIndex(of: "["),
              let end = text.lastIndex(of: "]"),
              start < end else {
            return nil
        }

        let jsonString = String(text[start...end])
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode([SuggestedHabitDraft].self, from: data)
    }

    private func parseLines(from text: String) -> [SuggestedHabitDraft] {
        let lines = text.split(whereSeparator: \.isNewline)
        var items: [SuggestedHabitDraft] = []

        for lineSub in lines {
            let rawLine = String(lineSub).trimmingCharacters(in: .whitespacesAndNewlines)
            let cleaned = rawLine.trimmingCharacters(in: CharacterSet(charactersIn: "-*0123456789. "))
            guard !cleaned.isEmpty else { continue }

            let parts = cleaned.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let title = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let details = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty {
                    items.append(SuggestedHabitDraft(title: title, details: details))
                }
            } else {
                items.append(SuggestedHabitDraft(title: cleaned, details: "Generated habit suggestion."))
            }
        }

        return items
    }

    private func trim(items: [SuggestedHabitDraft], expectedCount: Int) -> [SuggestedHabitDraft] {
        var result: [SuggestedHabitDraft] = []

        for item in items {
            let title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let details = item.details.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !title.isEmpty else { continue }

            let normalizedDetails = details.isEmpty ? "Generated habit suggestion." : details
            result.append(SuggestedHabitDraft(title: title, details: normalizedDetails))
        }

        if result.count > expectedCount {
            return Array(result.prefix(expectedCount))
        }

        return result
    }

    private func decodeServerError(from data: Data) -> String? {
        if let error = try? JSONDecoder().decode(HFErrorResponse.self, from: data) {
            return error.error
        }
        return nil
    }

    private func decodeBodyText(from data: Data) -> String? {
        guard let raw = String(data: data, encoding: .utf8) else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private struct HFRequest: Encodable {
    let inputs: String
    let parameters: HFParameters
    let options: HFOptions
}

private struct HFParameters: Encodable {
    let maxNewTokens: Int
    let temperature: Double
    let returnFullText: Bool

    enum CodingKeys: String, CodingKey {
        case maxNewTokens = "max_new_tokens"
        case temperature
        case returnFullText = "return_full_text"
    }
}

private struct HFGeneratedText: Decodable {
    let generated_text: String
}

private struct HFErrorResponse: Decodable {
    let error: String

    private enum CodingKeys: String, CodingKey {
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let message = try? container.decode(String.self, forKey: .error) {
            error = message
            return
        }

        if let detail = try? container.decode(HFErrorDetail.self, forKey: .error) {
            error = detail.message
            return
        }

        throw DecodingError.dataCorruptedError(
            forKey: .error,
            in: container,
            debugDescription: "Missing error message"
        )
    }

    private struct HFErrorDetail: Decodable {
        let message: String
    }
}

private struct HFOptions: Encodable {
    let waitForModel: Bool
    let useCache: Bool

    enum CodingKeys: String, CodingKey {
        case waitForModel = "wait_for_model"
        case useCache = "use_cache"
    }
}

