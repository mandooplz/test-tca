//
//  ItemFormFeature.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//
/* 전체 흐름
 [InventoryView]
    버튼 "추가" → store.send(.addButtonTapped)
         ↓
 [InventoryFeature.Reducer]
    addItem = ItemFormFeature.State()   // 모달 띄우기 신호
         ↓
 SwiftUI sheet 표시
         ↓
 [ItemFormView]
    버튼 "저장" → store.send(.saveButtonTapped)
         ↓
 [ItemFormFeature.Reducer]
    (여기선 로직 없음, 부모가 처리함)
         ↓
 [InventoryFeature.Reducer]
    case .addItem(.presented(.saveButtonTapped)):
         addItem = nil   // 모달 닫기
         ↓
 SwiftUI sheet dismiss
 
 왜 트리 구조?
 nventoryFeature (루트)
 └── addItem (모달)
   └── ItemFormFeature

 이건 트리 구조(부모 → 자식) 이다.
 */

// Tree-based navigation 테스트
import SwiftUI
import ComposableArchitecture


// 자식/모달
@Reducer
struct ItemFormFeature {
    @ObservableState
    struct State: Equatable {
        var name: String = ""
    }

    enum Action: Equatable {
        case nameChanged(String)
        case saveButtonTapped
        case cancelButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(text):
                state.name = text
                return .none

            case .saveButtonTapped:
                return .none

            case .cancelButtonTapped:
                return .none
            }
        }
    }
}

struct ItemFormView: View {
    @Bindable var store: StoreOf<ItemFormFeature>

    var body: some View {
        NavigationStack {
            Form {
                TextField(
                    "이름을 입력하세요",
                    text: $store.name.sending(\.nameChanged)
                )
            }
            .navigationTitle("아이템 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        store.send(.cancelButtonTapped)
                    }
                }
                //여기서 store는 자식 Store / 즉,ItemFormFeature.Action.saveButtonTapped 트리거
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        store.send(.saveButtonTapped)
                    }
                }
            }
        }
    }
}

