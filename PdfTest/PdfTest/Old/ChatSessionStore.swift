//
//  ChatSessionStore.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import Foundation
import SwiftUI
import Combine   // ✅ ObservableObjectPublisher

@MainActor
final class ChatSessionStore: ObservableObject {

    // ✅ ObservableObject 요구사항을 명시적으로 구현
    typealias ObjectWillChangePublisher = ObservableObjectPublisher
    let objectWillChange = ObservableObjectPublisher()

    // ✅ 값 변경 시 objectWillChange.send() 직접 호출
    var currentItem: SummaryPDF? {
        willSet { objectWillChange.send() }
    }

    var contextText: String = "" {
        willSet { objectWillChange.send() }
    }
}
