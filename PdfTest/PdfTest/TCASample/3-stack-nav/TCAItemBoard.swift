////
////  TCAItemBoard.swift
////  PdfTest
////
////  Created by 김민우 on 11/15/25.
////
//import Foundation
//import ComposableArchitecture
//
//// TCA에서는 내비게이션 경로를 객체가 상태로서 가진다.
//
//// MARK: Object
//@Reducer
//struct TCAItemBoard: Equatable {
//    // MARK: path
//    @Reducer
//    enum Path {
//        case addItem(TCAItem)
//    }
//    
//    // MARK: state
//    @ObservableState
//    struct State {
//        var items: [TCAItem.Model] = [
//            .init(id: UUID(), title: "Swift 공부", description: "TCA, Concurrency 복습"),
//            .init(id: UUID(), title: "iOS UI 만들기", description: "NavigationStack + TCA"),
//            .init(id: UUID(), title: "Side Project", description: "ItemBoard 앱 완성하기")
//        ]
//        var path = StackState<Path.State>()
//    }
//    
//    
//    // MARK: action
//    enum Action {
//        // NavigationStackStore와 연결되는 액션
//        case path(StackActionOf<Path>)
//
//        // 내비게이션 액션
//        case itemTapped(id: UUID)
//    }
//    
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//
//            case let .itemTapped(id):
//                // 리스트에서 선택된 아이템 찾아서
//                guard let item = state.items.first(where: { $0.id == id }) else {
//                    return .none
//                }
//                // detail 화면을 스택에 push
//                state.path.append(.addItem(TCAItem.State(item: item)))
//                return .none
//
//            case .path:
//                // 자식 화면에서 발생하는 액션은 여기서 처리하거나 흘려보낼 수 있음
//                return .none
//            }
//        }
//        // path에 쌓인 각 화면에 대한 리듀서 연결
//        .forEach(\.path, action: \.path)
//    }
//}
//
//
//// MARK: Object
//@Reducer
//struct TCAItem {
//    // MARK: state
//    @ObservableState
//    struct State: Equatable {
//        var item: Model
//    }
//    
//    // MARK: action
//    enum Action {
//        // 여기서는 단순히 읽기만 한다고 가정 (수정, 삭제 액션은 생략)
//    }
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            return
//        }
//    }
//    
//    
//    // MARK: value
//    struct Model: Hashable, Equatable {
//        // MARK: core
//        let id: UUID
//        let title: String
//        let description: String
//        
//        // MARK: operator
//        func withTitle(_ newValue: String) -> Self {
//            return .init(id: id, title: newValue, description: description)
//        }
//        func withDescription(_ newValue: String) -> Self {
//            return .init(id: id, title: title, description: newValue)
//        }
//    }
//}
