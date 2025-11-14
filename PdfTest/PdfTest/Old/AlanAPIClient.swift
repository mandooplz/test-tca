//
//  AlanAPIClient.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//
import Foundation

struct AlanAction: Decodable {
    let name: String?
    let speak: String?
}

struct AlanResponse: Decodable {
    let action: AlanAction?
    let content: String
}

final class AlanAPIClient {
    private let baseURL: URL
    private let clientID: String
    
    init(baseURL: URL, clientID: String) {
        self.baseURL = baseURL
        self.clientID = clientID
    }
    
    // ✅ content를 넣었을 때 실제 URL 길이 계산용
    func urlLength(for content: String) -> Int {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("question"),
            resolvingAgainstBaseURL: false
        )!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "content", value: content)
        ]
        
        return components.url?.absoluteString.count ?? Int.max
    }
    
    /// PDF 텍스트 요약용 헬퍼 (원하면 사용)
    func summarizePDFText(_ text: String) async throws -> String {
        let prompt = """
        다음 PDF 내용을 한국어로 핵심만 요약해줘.

        \(text)
        """
        let response = try await question(content: prompt)
        return response.content
    }
    
    /// Alan /question API 호출
    func question(content: String) async throws -> AlanResponse {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("question"),
            resolvingAgainstBaseURL: false
        )!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "content", value: content)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print(">>> URL length =", url.absoluteString.count)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let bodyString = String(data: data, encoding: .utf8) ?? "<no body>"
        print("Alan HTTP status:", http.statusCode)
        print("Alan response body:", bodyString)
        
        guard (200..<300).contains(http.statusCode) else {
            throw NSError(
                domain: "AlanAPIError",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(bodyString)"]
            )
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(AlanResponse.self, from: data)
    }
}
