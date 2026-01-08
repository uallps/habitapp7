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
    nonisolated static let modelIdKey = "HUGGINGFACE_MODEL_ID"
    // Put your token here for local testing only. Do not commit it.
    nonisolated static let hardcodedToken = "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"
    nonisolated static let defaultModelId = "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B:nscale"

    nonisolated static func resolveApiToken() -> String? {
        let hardcoded = hardcodedToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if !hardcoded.isEmpty {
            return hardcoded
        }

        if let envToken = ProcessInfo.processInfo.environment[infoPlistTokenKey] {
            let trimmed = envToken.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

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

    nonisolated static func resolveModelId() -> String {
        if let envModel = ProcessInfo.processInfo.environment[modelIdKey] {
            let trimmed = envModel.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        if let plistModel = Bundle.main.object(forInfoDictionaryKey: modelIdKey) as? String {
            let trimmed = plistModel.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        return defaultModelId
    }
}

struct HuggingFaceClient {
    private let modelId: String
    private let apiToken: String
    private let session: URLSession

    init(
        modelId: String = HuggingFaceConfig.resolveModelId(),
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

    func generateHabitSuggestions(count: Int, focus: String?) async throws -> (modelId: String, drafts: [SuggestedHabitDraft]) {
        let drafts = try await requestSuggestions(modelId: modelId, count: count, focus: focus)
        return (modelId, drafts)
    }

    private func requestSuggestions(modelId: String, count: Int, focus: String?) async throws -> [SuggestedHabitDraft] {
        let prompt = buildPrompt(count: count, focus: focus)
        let requestBody = HFChatRequest(
            model: modelId,
            messages: [
                HFChatMessage(role: "system", content: "You are a helpful habit coach."),
                HFChatMessage(role: "user", content: prompt)
            ],
            temperature: 0.7,
            maxTokens: 320
        )

        var request = URLRequest(url: chatURL())
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

        if let response = try? JSONDecoder().decode(HFChatResponse.self, from: data),
           let text = response.choices.first?.message.content {
            return parseGeneratedText(text, expectedCount: count)
        }

        if let error = decodeServerError(from: data) {
            throw HuggingFaceError.server(error)
        }

        if let body = decodeBodyText(from: data) {
            throw HuggingFaceError.server("Unexpected response: \(body)")
        }

        throw HuggingFaceError.decodingFailed
    }

    private func chatURL() -> URL {
        URL(string: "https://router.huggingface.co/v1/chat/completions")!
    }

    private func buildPrompt(count: Int, focus: String?) -> String {
        var prompt = "Generate \(count) habit suggestions in Spanish. "
        prompt += "Return ONLY a raw JSON array (no markdown) of objects with keys "
        prompt += "\"title\", \"details\", and \"frequency\". "
        prompt += "The \"details\" should be a short description. "
        prompt += "The \"frequency\" should be a short string like \"Diaria\", "
        prompt += "\"Semanal\", \"3 veces/semana\", or \"Lunes a Viernes\". "
        prompt += "Keep titles short and practical."

        if let focus, !focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            prompt += " Focus on: \(focus)."
        }

        return prompt
    }

    private func parseGeneratedText(_ text: String, expectedCount: Int) -> [SuggestedHabitDraft] {
        let cleaned = sanitizeGeneratedText(text)
        if let jsonItems = decodeJSONItems(from: cleaned) {
            return trim(items: jsonItems, expectedCount: expectedCount)
        }

        let fallbackItems = parseLines(from: cleaned)
        return trim(items: fallbackItems, expectedCount: expectedCount)
    }

    private func decodeJSONItems(from text: String) -> [SuggestedHabitDraft]? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = trimmed.data(using: .utf8) {
            if let direct = try? JSONDecoder().decode([SuggestedHabitDraft].self, from: data) {
                return direct
            }
            if let wrapped = try? JSONDecoder().decode(HFHabitsWrapper.self, from: data) {
                return wrapped.habits
            }
        }

        guard let start = text.firstIndex(of: "["),
              let end = text.lastIndex(of: "]"),
              start < end else {
            return nil
        }

        let jsonString = String(text[start...end])
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        if let direct = try? JSONDecoder().decode([SuggestedHabitDraft].self, from: data) {
            return direct
        }
        if let wrapped = try? JSONDecoder().decode(HFHabitsWrapper.self, from: data) {
            return wrapped.habits
        }
        return nil
    }

    private func parseLines(from text: String) -> [SuggestedHabitDraft] {
        let lines = text.split(whereSeparator: \.isNewline)
        var items: [SuggestedHabitDraft] = []

        for lineSub in lines {
            let rawLine = String(lineSub).trimmingCharacters(in: .whitespacesAndNewlines)
            let cleaned = rawLine.trimmingCharacters(in: CharacterSet(charactersIn: "-*0123456789. "))
            guard !cleaned.isEmpty else { continue }

            let dashParts = cleaned.split(separator: "-", maxSplits: 2).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if dashParts.count == 3 {
                let title = dashParts[0]
                let details = dashParts[1]
                let frequency = dashParts[2]
                if !title.isEmpty {
                    items.append(
                        SuggestedHabitDraft(title: title, details: details, frequency: frequency)
                    )
                }
                continue
            }

            let parts = cleaned.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let title = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let details = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty {
                    items.append(
                        SuggestedHabitDraft(title: title, details: details, frequency: nil)
                    )
                }
            } else {
                items.append(
                    SuggestedHabitDraft(
                        title: cleaned,
                        details: "Generated habit suggestion.",
                        frequency: nil
                    )
                )
            }
        }

        return items
    }

    private func trim(items: [SuggestedHabitDraft], expectedCount: Int) -> [SuggestedHabitDraft] {
        var result: [SuggestedHabitDraft] = []

        for item in items {
            let title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let details = item.details.trimmingCharacters(in: .whitespacesAndNewlines)
            let frequency = (item.frequency ?? "Flexible")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !title.isEmpty else { continue }

            let normalizedDetails = details.isEmpty ? "Generated habit suggestion." : details
            let normalizedFrequency = frequency.isEmpty ? "Flexible" : frequency
            result.append(
                SuggestedHabitDraft(
                    title: title,
                    details: normalizedDetails,
                    frequency: normalizedFrequency
                )
            )
        }

        if result.count > expectedCount {
            return Array(result.prefix(expectedCount))
        }

        return result
    }

    private func sanitizeGeneratedText(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let firstFence = trimmed.range(of: "```") else {
            return trimmed
        }
        guard let lastFence = trimmed.range(
            of: "```",
            options: .backwards,
            range: firstFence.upperBound..<trimmed.endIndex
        ) else {
            return trimmed
        }

        var inner = String(trimmed[firstFence.upperBound..<lastFence.lowerBound])
        inner = inner.trimmingCharacters(in: .whitespacesAndNewlines)
        if inner.hasPrefix("json") {
            inner = String(inner.dropFirst(4))
            inner = inner.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return inner
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

private struct HFChatRequest: Encodable {
    let model: String
    let messages: [HFChatMessage]
    let temperature: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}

private struct HFChatMessage: Encodable {
    let role: String
    let content: String
}

private struct HFChatResponse: Decodable {
    let choices: [HFChatChoice]
}

private struct HFChatChoice: Decodable {
    let message: HFChatMessageContent
}

private struct HFChatMessageContent: Decodable {
    let content: String
}

private struct HFHabitsWrapper: Decodable {
    let habits: [SuggestedHabitDraft]
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
