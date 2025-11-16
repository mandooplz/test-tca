# 4-tree-nav — 트리 기반 네비게이션 & 모달

부모 피처 하나가 여러 모달/시트를 자식 피처로 관리하며 트리처럼 액션을 전달합니다.

## TCA 기능, 설명, 예시 코드

### 1. `@Presents`로 모달 상태 선언
- 설명: 부모 상태에 자식 모달(`addItem`, `detail`, `filter`)을 optional 로 보관하고 nil 여부로 표시 여부를 제어합니다.
```swift
@Reducer
struct InventoryFeature {
    @ObservableState
    struct State: Equatable {
        var items: [Item] = []
        var showLongNames = false

        @Presents var addItem: ItemFormFeature.State?
        @Presents var detail: ItemDetailFeature.State?
        @Presents var filter: FilterFeature.State?
    }
    ...
}
```

### 2. `PresentationAction`으로 자식 액션 처리
- 설명: 자식 모달에서 올라온 액션은 `.presented` 형태로 감싸져 부모 리듀서가 저장/취소/닫기를 구분할 수 있습니다.
```swift
enum Action: Equatable {
    case addButtonTapped
    case addItem(PresentationAction<ItemFormFeature.Action>)
    case itemTapped(UUID)
    case detail(PresentationAction<ItemDetailFeature.Action>)
    case filterButtonTapped
    case filter(PresentationAction<FilterFeature.Action>)
    case delete(ids: [UUID])
}

var body: some Reducer<State, Action> {
    Reduce { state, action in
        switch action {
        case .addButtonTapped:
            state.addItem = ItemFormFeature.State()
            return .none

        case .addItem(.presented(.saveButtonTapped)):
            guard let formState = state.addItem else { return .none }
            state.items.append(.init(id: UUID(), name: formState.name))
            state.addItem = nil
            return .none

        case .detail(.presented(.closeButtonTapped)):
            state.detail = nil
            return .none
        ...
        }
    }
```
```

### 3. `.ifLet` + `.sheet`로 SwiftUI와 연결
- 설명: 자식 상태가 있을 때만 리듀서를 실행하고, 동일한 상태를 SwiftUI `sheet`에 스코프합니다.
```swift
var body: some Reducer<State, Action> {
    Reduce { ... }
    .ifLet(\.$addItem, action: \.addItem) { ItemFormFeature() }
    .ifLet(\.$detail, action: \.detail) { ItemDetailFeature() }
    .ifLet(\.$filter, action: \.filter) { FilterFeature() }
}

struct InventoryView: View {
    @Bindable var store: StoreOf<InventoryFeature>

    var body: some View {
        NavigationStack {
            List { ... }
            .sheet(
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
```
