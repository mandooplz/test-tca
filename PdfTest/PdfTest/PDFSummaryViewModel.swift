//
//  PDFSummaryViewModel.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//
import Foundation
import SwiftUI   // 중요: SwiftUI가 ObservableObject와 @Published를 가져옴
import Combine

@MainActor
final class PDFSummaryViewModel: ObservableObject {
    // ObservableObject 합성용 @Published 프로퍼티들
    @Published var isLoading: Bool = false
    @Published var originalText: String = ""
    @Published var summaryText: String = ""
    @Published var errorMessage: String?
    @Published var lastDuration: TimeInterval?
    
    private let alanClient: AlanAPIClient
    
    init() {
        // Alan API base URL
        let baseURL = URL(string: "https://kdt-api-function.azurewebsites.net/api/v1")!
        
        // ✅ 여기다가 실제 ALAN_CLIENT_KEY 넣기
        // 예: 대시보드나 문서에서 받은 클라이언트 키 문자열
        let alanClientKey = "d6027b9d-710f-4c04-ab63-550aa2cb6b8c"

        
        // 이 키가 그대로 client_id로 나가게 됨
        self.alanClient = AlanAPIClient(baseURL: baseURL, clientID: alanClientKey)
    }
    
    func importPDF(from url: URL) {
        guard let text = PDFTextExtractor.extractText(from: url) else {
            self.errorMessage = "PDF 텍스트를 추출할 수 없습니다."
            return
        }
        self.originalText = text
    }
    
//    func summarize() {
//        let text = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !text.isEmpty else {
//            self.errorMessage = "먼저 PDF를 선택해 내용을 불러와야 합니다."
//            return
//        }
//        
//        Task {
//            do {
//                isLoading = true
//                errorMessage = nil
//                
//                // 너무 길어지는 걸 방지해서 앞부분만 사용 (필요시 chunk 로직 추가)
//                let limitedText = String(text.prefix(10_000))
//                
//                let result = try await alanClient.summarizePDFText(limitedText)
//                self.summaryText = result
//            } catch {
//                self.errorMessage = "요약 중 오류: \(error.localizedDescription)"
//            }
//            isLoading = false
//        }
//    }
    
//    func summarize() {
//        Task {
//            do {
//                isLoading = true
//                errorMessage = nil
//                
//                // ✅ 테스트용: PDF 말고 그냥 한 줄 질문
//                let result = try await alanClient.question(
//                    content: "아이즈원과 에스파의 인기를 비교해줘"
//                )
//                self.summaryText = result.content
//            } catch {
//                self.errorMessage = "요약 중 오류: \(error.localizedDescription)"
//                print("Alan error:", error)
//            }
//            isLoading = false
//        }
//    }
    
    //하나씩 호출하기
//    func summarize() {
//        var text = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !text.isEmpty else {
//            self.errorMessage = "먼저 PDF를 선택해 내용을 불러와야 합니다."
//            return
//        }
//
//        // 1) 불필요한 줄바꿈/탭 제거
//        text = text
//            .replacingOccurrences(of: "\r", with: " ")
//            .replacingOccurrences(of: "\n", with: " ")
//            .replacingOccurrences(of: "\t", with: " ")
//            .replacingOccurrences(of: "  ", with: " ")
//
//        // 2) 일단 크게 잘라서 chunk 생성 (예: 2000자 시작)
//        let rawChunks = chunk(text: text, size: 2000)
//
//        Task {
//            do {
//                isLoading = true
//                errorMessage = nil
//                summaryText = ""
//                lastDuration = nil
//
//                let startTime = Date()
//                var partialSummaries: [String] = []
//
//                // 3) 각 chunk마다 URL 길이를 보면서 줄이기
//                let maxURLLength = 8000
//
//                for (index, rawChunk) in rawChunks.enumerated() {
//                    var chunkText = rawChunk
//
//                    // URL 길이가 maxURLLength 이하가 될 때까지 chunkText 줄이기
//                    while true {
//                        let prompt = "다음 내용을 한국어로 2~3줄로 요약:\n\(chunkText)"
//                        let urlLen = alanClient.urlLength(for: prompt)
//
//                        print(">>> chunk", index + 1,
//                              "chars =", chunkText.count,
//                              "URL length =", urlLen)
//
//                        if urlLen <= maxURLLength {
//                            // 여기서 확정
//                            let response = try await alanClient.question(content: prompt)
//                            partialSummaries.append("● \(response.content)")
//                            break
//                        }
//
//                        // 너무 길면 chunkText를 줄인다. (20%씩 줄이기)
//                        let newCount = Int(Double(chunkText.count) * 0.8)
//                        if newCount < 200 {
//                            // 200자 이하로 줄였는데도 URL이 길면 그냥 이 상태로 보냄
//                            let response = try await alanClient.question(content: prompt)
//                            partialSummaries.append("● \(response.content)")
//                            break
//                        }
//
//                        chunkText = String(chunkText.prefix(newCount))
//                    }
//                }
//
//                self.summaryText = partialSummaries.joined(separator: "\n\n")
//
//                let endTime = Date()
//                let duration = endTime.timeIntervalSince(startTime)
//                self.lastDuration = duration
//                print(">>> 전체 요약 소요 시간: \(duration)초 (~\(duration/60)분)")
//
//            } catch {
//                self.errorMessage = "요약 중 오류: \(error.localizedDescription)"
//                print("Alan error:", error)
//            }
//            isLoading = false
//        }
//    }

    //병렬 호출
    func summarize() {
        var text = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            self.errorMessage = "먼저 PDF를 선택해 내용을 불러와야 합니다."
            return
        }

        // 1) 불필요한 줄바꿈/탭/중복 공백 정리
        text = text
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")

        // 2) 전체 텍스트를 크게 잘라서 chunk 생성 (문서 전체 대상)
        //    17,000자면 size 2,000 기준으로 대략 8~9개 chunk
        let rawChunks = chunk(text: text, size: 2000)

        Task {
            do {
                isLoading = true
                errorMessage = nil
                summaryText = ""
                lastDuration = nil

                let startTime = Date()
                let maxURLLength = 8000

                // 결과를 index 순서대로 저장하기 위한 버퍼
                var partialSummaries = Array(repeating: "", count: rawChunks.count)

                // ✅ 병렬 호출: 모든 chunk를 TaskGroup으로 동시에 Alan에 요청
                try await withThrowingTaskGroup(of: (Int, String).self) { group in
                    for (index, rawChunk) in rawChunks.enumerated() {

                        group.addTask { [alanClient] in
                            var chunkText = rawChunk

                            while true {
                                let prompt = "다음 내용을 한국어로 2~3줄로 요약:\n\(chunkText)"
                                let urlLen = await alanClient.urlLength(for: prompt)

                                print(">>> chunk", index + 1,
                                      "chars =", chunkText.count,
                                      "URL length =", urlLen)

                                if urlLen <= maxURLLength {
                                    // URL 길이 제한 안이면 실제 호출
                                    let response = try await alanClient.question(content: prompt)
                                    return (index, "● \(response.content)")
                                }

                                // 너무 길면 chunkText를 줄인다. (20%씩 줄이기)
                                let newCount = Int(Double(chunkText.count) * 0.8)
                                if newCount < 200 {
                                    // 200자 이하까지 줄였는데도 여전히 길면 그냥 보냄
                                    let response = try await alanClient.question(content: prompt)
                                    return (index, "● \(response.content)")
                                }

                                chunkText = String(chunkText.prefix(newCount))
                            }
                        }
                    }

                    // 병렬 작업들이 끝나는 순서대로 결과 수집, index 기준으로 정렬
                    for try await (index, summary) in group {
                        partialSummaries[index] = summary
                    }
                }

                // index 순서 유지해서 하나의 문자열로 합치기
                self.summaryText = partialSummaries.joined(separator: "\n\n")

                let endTime = Date()
                let duration = endTime.timeIntervalSince(startTime)
                self.lastDuration = duration
                print(">>> 병렬 전체 요약 소요 시간: \(duration)초 (~\(duration/60)분)")

            } catch {
                self.errorMessage = "요약 중 오류: \(error.localizedDescription)"
                print("Alan error:", error)
            }
            isLoading = false
        }
    }

    
    private func chunk(text: String, size: Int) -> [String] {
        var result: [String] = []
        var current = text.startIndex

        while current < text.endIndex {
            let end = text.index(current, offsetBy: size,
                                 limitedBy: text.endIndex) ?? text.endIndex
            result.append(String(text[current..<end]))
            current = end
        }
        return result
    }
}
