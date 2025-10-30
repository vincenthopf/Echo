import Foundation

class SonioxTranscriptionService {
    private let apiBase = "https://api.soniox.com/v1"

    func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        let config = try getAPIConfig(for: model)

        let fileId = try await uploadFile(audioURL: audioURL, apiKey: config.apiKey)
        let transcriptionId = try await createTranscription(fileId: fileId, apiKey: config.apiKey, modelName: model.name)
        try await pollTranscriptionStatus(id: transcriptionId, apiKey: config.apiKey)
        let transcript = try await fetchTranscript(id: transcriptionId, apiKey: config.apiKey)

        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CloudTranscriptionError.noTranscriptionReturned
        }
        return transcript
    }

    private func getAPIConfig(for model: any TranscriptionModel) throws -> APIConfig {
        guard let apiKey = UserDefaults.standard.string(forKey: "SonioxAPIKey"), !apiKey.isEmpty else {
            throw CloudTranscriptionError.missingAPIKey
        }
        return APIConfig(apiKey: apiKey)
    }

    private func uploadFile(audioURL: URL, apiKey: String) async throws -> String {
        guard let apiURL = URL(string: "\(apiBase)/files") else {
            throw CloudTranscriptionError.dataEncodingError
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = try createMultipartBody(fileURL: audioURL, boundary: boundary)
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudTranscriptionError.networkError(URLError(.badServerResponse))
        }
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "No error message"
            throw CloudTranscriptionError.apiRequestFailed(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        do {
            let uploadResponse = try JSONDecoder().decode(FileUploadResponse.self, from: data)
            return uploadResponse.id
        } catch {
            throw CloudTranscriptionError.noTranscriptionReturned
        }
    }

    private func createTranscription(fileId: String, apiKey: String, modelName: String) async throws -> String {
        guard let apiURL = URL(string: "\(apiBase)/transcriptions") else {
            throw CloudTranscriptionError.dataEncodingError
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var payload: [String: Any] = [
            "file_id": fileId,
            "model": modelName,
            // Disable diarization as per app requirement
            "enable_speaker_diarization": false
        ]
        // Attach custom vocabulary terms from the app's dictionary (if any)
        let dictionaryTerms = getCustomDictionaryTerms()
        if !dictionaryTerms.isEmpty {
            payload["context"] = [
                "terms": dictionaryTerms
            ]
        }
        let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "auto"
        if selectedLanguage != "auto" && !selectedLanguage.isEmpty {
            payload["language_hints"] = [selectedLanguage]
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudTranscriptionError.networkError(URLError(.badServerResponse))
        }
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "No error message"
            throw CloudTranscriptionError.apiRequestFailed(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        do {
            let createResponse = try JSONDecoder().decode(CreateTranscriptionResponse.self, from: data)
            return createResponse.id
        } catch {
            throw CloudTranscriptionError.noTranscriptionReturned
        }
    }

    private func pollTranscriptionStatus(id: String, apiKey: String) async throws {
        guard let baseURL = URL(string: "\(apiBase)/transcriptions/\(id)") else {
            throw CloudTranscriptionError.dataEncodingError
        }
        let start = Date()
        let maxWaitSeconds: TimeInterval = 300
        while true {
            var request = URLRequest(url: baseURL)
            request.httpMethod = "GET"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CloudTranscriptionError.networkError(URLError(.badServerResponse))
            }
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "No error message"
                throw CloudTranscriptionError.apiRequestFailed(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            do {
                let status = try JSONDecoder().decode(TranscriptionStatusResponse.self, from: data)
                switch status.status.lowercased() {
                case "completed":
                    return
                case "failed":
                    throw CloudTranscriptionError.apiRequestFailed(statusCode: 500, message: "Transcription failed")
                default:
                    break
                }
            } catch {
                // Decoding status failed, will retry
            }
            if Date().timeIntervalSince(start) > maxWaitSeconds {
                throw CloudTranscriptionError.apiRequestFailed(statusCode: 504, message: "Transcription timed out")
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    private func fetchTranscript(id: String, apiKey: String) async throws -> String {
        guard let apiURL = URL(string: "\(apiBase)/transcriptions/\(id)/transcript") else {
            throw CloudTranscriptionError.dataEncodingError
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudTranscriptionError.networkError(URLError(.badServerResponse))
        }
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMessage = String(data: data, encoding: .utf8) ?? "No error message"
            throw CloudTranscriptionError.apiRequestFailed(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        if let decoded = try? JSONDecoder().decode(TranscriptResponse.self, from: data) {
            return decoded.text
        }
        if let asString = String(data: data, encoding: .utf8), !asString.isEmpty {
            return asString
        }
        throw CloudTranscriptionError.noTranscriptionReturned
    }

    private func createMultipartBody(fileURL: URL, boundary: String) throws -> Data {
        var body = Data()
        let crlf = "\r\n"
        guard let audioData = try? Data(contentsOf: fileURL) else {
            throw CloudTranscriptionError.audioFileNotFound
        }
        body.append("--\(boundary)\(crlf)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\(crlf)".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\(crlf)\(crlf)".data(using: .utf8)!)
        body.append(audioData)
        body.append(crlf.data(using: .utf8)!)
        body.append("--\(boundary)--\(crlf)".data(using: .utf8)!)
        return body
    }

    private func getCustomDictionaryTerms() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: "CustomDictionaryItems") else {
            return []
        }
        // Decode without depending on UI layer types; extract "word" strings
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        let words = json.compactMap { $0["word"] as? String }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        // De-duplicate while preserving order
        var seen = Set<String>()
        var unique: [String] = []
        for w in words {
            let key = w.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(w)
            }
        }
        return unique
    }

    private struct APIConfig { let apiKey: String }
    private struct FileUploadResponse: Decodable { let id: String }
    private struct CreateTranscriptionResponse: Decodable { let id: String }
    private struct TranscriptionStatusResponse: Decodable { let status: String }
    private struct TranscriptResponse: Decodable { let text: String }
}
