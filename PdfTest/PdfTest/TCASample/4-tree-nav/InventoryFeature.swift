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
    
    struct Item: Equatable, Identifiable{
        let id: UUID
        let name: String
    }
    
    @ObservableState
    struct State: Equatable {
        // 관리할 아이템 목록
        var items: [Item] = []
        
        var showLongNames = false
        
        // 모달에 쓰이는 자식 상태
        @Presents var addItem: ItemFormFeature.State?
        @Presents var detail: ItemDetailFeature.State?
        @Presents var filter: FilterFeature.State?
    }

    enum Action: Equatable {
        case addButtonTapped
        case addItem(PresentationAction<ItemFormFeature.Action>)
        
        case itemTapped(UUID)
        case detail(PresentationAction<ItemDetailFeature.Action>)
        
        case filterButtonTapped
        case filter(PresentationAction<FilterFeature.Action>)
        
        case delete(ids: [UUID]) // 삭제 액션 추가
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
                
            case .filterButtonTapped:
                state.filter = FilterFeature.State(
                    showNames: state.showLongNames
                )
                return .none

            // 아이템 탭하면 -> 상세 화면 열기
            case let .itemTapped(id):
                if let item = state.items.first(where: { $0.id == id }) {
                    state.detail = ItemDetailFeature.State(item: item)
                }
                return .none
                
            // PresentationAction이 핵심
            // addItem 이 "자식 화면"이기 때문에
            // 자식 액션은 무조건 .addItem(.presented(...)) 형태로 올라와.
            // TCA가 자동으로 해주는 기능
            case .addItem(.presented(.saveButtonTapped)):
                guard let formState = state.addItem else {
                    return .none
                }
                
                let newItem = Item(
                    id: UUID(),
                    name: formState.name
                )
                
                state.items.append(newItem)
                state.addItem = nil
                return .none

            case .addItem(.presented(.cancelButtonTapped)):
                state.addItem = nil
                return .none
                
            case .detail(.presented(.closeButtonTapped)):
                state.detail = nil
                return .none
                
            case .filter(.presented(.cancelButtonTapped)):
                state.filter = nil
                return .none
                
            case .filter(.presented(.applyButtonTapped)):
                if let filterState = state.filter {
                    state.showLongNames = filterState.showNames
                }
                state.filter = nil
                return .none
                
            case .addItem, .detail, .filter:
                return .none
                
            case let .delete(ids):
                state.items.removeAll { item in
                    ids.contains(item.id)
                }
                return .none
                
            }
        }
        .ifLet(\.$addItem, action: \.addItem) {
            ItemFormFeature()
        }
        .ifLet(\.$detail, action: \.detail){
            ItemDetailFeature()
        }
        .ifLet(\.$filter, action: \.filter){
            FilterFeature()
        }
    }
}

struct InventoryView: View {
    @Bindable var store: StoreOf<InventoryFeature>

    var body: some View {
        NavigationStack {
            let filteredItems: [InventoryFeature.Item] = {
                if store.showLongNames {
                    return store.items.filter {$0.name.count >= 5}
                } else {
                    return store.items
                }
            }()

            List {
                if store.items.isEmpty {
                    Text("아이템 없다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }else {
                    ForEach(filteredItems) { item in
                        Button {
                            store.send(.itemTapped(item.id))
                        } label: {
                            Text(item.name)
                        }
                    }
                    .onDelete{ indexSet in
                        let ids = indexSet.map { filteredItems[$0].id }
                        store.send(.delete(ids: ids))
                    }
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    HStack {
                        Button("필터") {
                            store.send(.filterButtonTapped)
                        }
                        
                        // 내가 추가 버튼을 누르면 -> Action 발생하지. -> View 모르고 그냥 " 이 상황에서 이 액션 보내"만 수행 (body로 가는 거지?)
                        Button("추가") {
                            store.send(.addButtonTapped)
                        }
                    }
                }
            }
            // addItem 이 nil 아니면 -> sheet 표시
            // addItem 이 값이 있으면 -> sheet 표시 후 ItemFormView(store:...)실행
            // SwiftUI는 addItem 값의 존재 여부만 보고 sheet를 띄우는 게 아니라
            // Store와 연결된 값으로 중첩된 "자식 store"도 넘겨준다.
            // 그래서 ItemFormView에서도 store.send()를 하게 되면 ItemFormFeature.Action으로 전달....?
            .sheet(
                // .sheet~ 이거는
                // item이 nill이면 dismiss, item이 값이 있으면 present 규칙
                // 부모 Reducer에서 상태를 nil로 바꾸는 순간 sheet도 닫힌다.
                item: $store.scope(state: \.addItem, action: \.addItem)
            ) { store in
                ItemFormView(store: store)
            }
           
            .sheet(
                item: $store.scope(state: \.detail, action: \.detail)
            ) { store in
                ItemDetailView(store: store)
            }
            
            .sheet(
                item: $store.scope(state: \.filter, action: \.filter)
            ) { store in
                FilterView(store: store)
            }
        }
    }
}

