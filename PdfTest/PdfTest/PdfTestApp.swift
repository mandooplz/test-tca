//
//  PdfTestApp.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import SwiftUI
import SwiftData

@main
struct PdfTestApp: App {
    @StateObject private var chatStore = ChatSessionStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(chatStore)
        }
        .modelContainer(for: [SummaryPDF.self, ChatMessageEntity.self])  // ✅ 여기
    }
}

