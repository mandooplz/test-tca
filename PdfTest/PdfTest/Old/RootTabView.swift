//
//  RootTabView.swift
//  PdfTest
//

import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 탭 1: PDF 요약
            PDFSummaryView()
                .tabItem {
                    Label("요약", systemImage: "doc.text.magnifyingglass")
                }
                .tag(0)

            // 탭 2: 프로젝트 리스트
            SavedSummaryListView(onOpenChatTab: {
                // 상세 화면에서 "채팅" 버튼 눌렀을 때 3번째 탭으로 전환
                selectedTab = 2
            })
            .tabItem {
                Label("프로젝트", systemImage: "folder")
            }
            .tag(1)

            // 탭 3: 채팅
            ChatTabView()
                .tabItem {
                    Label("채팅", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(2)
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(ChatSessionStore())
}
