//
//  ChatMessageEntity.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import Foundation
import SwiftData

@Model
final class ChatMessageEntity {
    var id: UUID
    var createdAt: Date
    var isUser: Bool
    var text: String

    // 어떤 프로젝트(SummaryPDF)에 속한 메시지인지
    var project: SummaryPDF?

    init(id: UUID = UUID(),
         createdAt: Date = Date(),
         isUser: Bool,
         text: String,
         project: SummaryPDF? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.isUser = isUser
        self.text = text
        self.project = project
    }
}

