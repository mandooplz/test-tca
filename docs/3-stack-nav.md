# 3-stack-nav — NavigationStack 연동

`StackState`로 네비게이션 경로를 상태화하고, SwiftUI `NavigationStack`과 Store를 직접 바인딩합니다.

## TCA 기능, 설명, 예시 코드

### 1. `StackState`/`StackAction`으로 경로 상태화
- 설명: `path`를 `StackState`로 두고, `enum Path` 안에 push될 화면을 선언합니다.
```swift
@Reducer
struct TCAItemBoard {
    @Reducer
    enum Path {
        case addItem(TCAItem)
    }

    @ObservableState
    struct State {
        var items: [TCAItem.Model] = [
            .init(id: UUID(), title: "Swift 공부", description: "TCA, Concurrency 복습"),
            .init(id: UUID(), title: "iOS UI 만들기", description: "NavigationStack + TCA"),
            .init(id: UUID(), title: "Side Project", description: "ItemBoard 앱 완성하기")
        ]
        var path = StackState<Path.State>()
    }

    enum Action {
        case path(StackActionOf<Path>)
        case itemTapped(id: UUID)
    }
}
```

### 2. `.forEach`로 경로별 자식 리듀서 연결
- 설명: `state.path.append`로 push하고, `.forEach`가 경로에 맞는 자식 리듀서를 실행합니다.
```swift
var body: some Reducer<State, Action> {
    Reduce { state, action in
        switch action {
        case let .itemTapped(id):
            guard let item = state.items.first(where: { $0.id == id }) else {
                return .none
            }
            state.path.append(.addItem(TCAItem.State(item: item)))
            return .none

        case .path:
            return .none
        }
    }
    .forEach(\.path, action: \.path)
}
```

### 3. `NavigationStack`과 Store 바인딩
- 설명: SwiftUI `NavigationStack`의 `path`를 Store에 스코프하고, destination에서 각 케이스별 뷰를 구성합니다.
```swift
struct TCAItemBoardView: View {
    @State var store: StoreOf<TCAItemBoard>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            List {
                ForEach(store.items, id: \.id) { item in
                    Button {
                        store.send(.itemTapped(id: item.id))
                    } label: {
                        Text(item.title)
                    }
                }
            }
        } destination: { state in
            switch state.case {
            case .addItem(let store):
                TCAItemView(store: store)
            }
        }
    }
}
```
