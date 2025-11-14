//
//  SummaryPDF.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//
// SummaryPDF.swift
import Foundation
import SwiftData

@Model
final class SummaryPDF {
    var id: UUID
    var createdAt: Date
    var title: String
    var pdfFileName: String        // 요약 PDF 파일 이름 (없을 수 있음)

    var originalScriptText: String?   // ✅ 원본 PDF 전체 텍스트
    var aiSummaryText: String?        // ✅ Ai 요약 결과

    @Relationship(deleteRule: .cascade, inverse: \ChatMessageEntity.project)
    var messages: [ChatMessageEntity]

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        title: String,
        pdfFileName: String,
        originalScriptText: String? = nil,
        aiSummaryText: String? = nil,
        messages: [ChatMessageEntity] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.pdfFileName = pdfFileName
        self.originalScriptText = originalScriptText
        self.aiSummaryText = aiSummaryText
        self.messages = messages
    }
}
