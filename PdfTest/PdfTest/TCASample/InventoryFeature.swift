//
//  InventoryFeature.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

// Tree-based navigation 테스트
import SwiftUI
import ComposableArchitecture


//부모
@Reducer
struct InventoryFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var addItem: ItemFormFeature.State?
    }

    enum Action: Equatable {
        case addButtonTapped
        case addItem(PresentationAction<ItemFormFeature.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // addItem 값을 nill -> State 객체로 변경
            // addItem == nill -> 모달을 안띄우지.
            // addItem != nil -> 모달을 띄우지
            // 이게 핵심? SwiftUI가 어떤 화면을 띄울지가 아니라 -> State로 결정하는거
            case .addButtonTapped:
                state.addItem = ItemFormFeature.State()
                return .none

            // PresentationAction이 핵심
            // addItem 이 "자식 화면"이기 때문에
            // 자식 액션은 무조건 .addItem(.presented(...)) 형태로 올라와.
            // TCA가 자동으로 해주는 기능
            case .addItem(.presented(.saveButtonTapped)):
                state.addItem = nil
                return .none

            case .addItem(.presented(.cancelButtonTapped)):
                state.addItem = nil
                return .none

            case .addItem:
                return .none
            }
        }
        .ifLet(\.$addItem, action: \.addItem) {
            ItemFormFeature()
        }
    }
}

struct InventoryView: View {
    @Bindable var store: StoreOf<InventoryFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("여기는 인벤토리 메인 화면")
                    .font(.title)

                Text("오른쪽 위 '추가' 버튼을 눌러보세요")
                    .font(.subheadline)
            }
            .navigationTitle("Inventory")
            .toolbar {
                // 내가 추가 버튼을 누르면 -> Action 발생하지. -> View 모르고 그냥 " 이 상황에서 이 액션 보내"만 수행 (body로 가는 거지?)
                Button("추가") {
                    store.send(.addButtonTapped)
                }
            }
            // addItem 이 nil 아니면 -> sheet 표시
            // addItem 이 값이 있으면 -> sheet 표시 후 ItemFormView(store:...)실행
            // SwiftUI는 addItem 값의 존재 여부만 보고 sheet를 띄우는 게 아니라
            // Store와 연결된 값으로 중첩된 "자식 store"도 넘겨준다.
            // 그래서 ItemFormView에서도 store.send()를 하게 되면 ItemFormFeature.Action으로 전달....?
            .sheet(
                item: $store.scope(state: \.addItem, action: \.addItem)
            ) { store in
                ItemFormView(store: store)
            }
            // .sheet~ 이거는
            // item이 nill이면 dismiss, item이 값이 있으면 present 규칙
            // 부모 Reducer에서 상태를 nil로 바꾸는 순간 sheet도 닫힌다.
        }
    }
}

