//
//  PdfTestApp.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//
import SwiftUI
import SwiftData
import ComposableArchitecture


// Tree-based navigation 테스트
@main
struct PdfTestApp: App {
    @StateObject private var chatStore = ChatSessionStore()

    var body: some Scene {
        WindowGroup {
            InventoryView(
                // 생성,준비를 Store로 감싸서 InventoryView로 넘기지..?
                // 결국 InventoryView는 state와 action을 조종하는 것을 받고 시작하는 화면?
                            store: Store(
                                // InventoryFeature 부모 화면의 초기 상태 생성
                                initialState: InventoryFeature.State()
                            ) {
                                // 부모의 Reducer 준비
                                InventoryFeature()
                            }
                        )
            
//            RootTabView()
//                .environmentObject(chatStore)
        }
//        .modelContainer(for: [SummaryPDF.self, ChatMessageEntity.self])  // ✅ 여기
    }
}

