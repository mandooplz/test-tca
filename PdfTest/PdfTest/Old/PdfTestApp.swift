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
                store: Store(
                    initialState: InventoryFeature.State()
                ) {
                    InventoryFeature()
                }
            )
        }
    }
}

