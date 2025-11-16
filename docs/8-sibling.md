# 8-sibling — 형제 피처 간 상태 중계

컨트롤러와 뷰어라는 두 형제 피처를 하나의 부모가 감싸고, 자식 간 상태를 직접 공유하지 않고 부모 리듀서를 통해 전달하는 패턴을 다룹니다.

## TCA 기능, 설명, 예시 코드

### 1. 부모가 형제 피처의 상태를 모두 소유
- 설명: `TCAMainC.State`는 각 형제의 상태를 들고 있어 하나의 진실 공급원(Single Source of Truth)을 유지합니다.
```swift
@Reducer
struct TCAMainC {
    @ObservableState
    struct State {
        var controller = TCAController.State()
        var viewer = TCAViewer.State()
    }

    enum Action {
        case controller(TCAController.Action)
        case viewer(TCAViewer.Action)
    }
```

### 2. 액션을 부모에서 받아 상태를 다른 형제에게 반영
- 설명: 컨트롤러에서 `.increment`, `.decrement`를 보내면 부모가 그 액션을 받아 뷰어의 `count`를 조작합니다.
```swift
var body: some Reducer<State, Action> {
    Scope(state: \.controller, action: \.controller) { TCAController() }
    Scope(state: \.viewer, action: \.viewer) { TCAViewer() }

    Reduce { state, action in
        switch action {
        case .controller(.increment):
            state.viewer.count += 1
            return .none
        case .controller(.decrement):
            state.viewer.count -= 1
            return .none
        case .viewer:
            return .none
        }
    }
}
```

### 3. 형제별 View를 별도 파일로 구현하고 부모에서 스코프
- 설명: 부모 View(`TCAMainCView`)는 각 피처의 View 파일을 스코프된 Store로 주입해 독립적인 UI를 구성합니다.
```swift
struct TCAMainCView: View {
    @Bindable var store: StoreOf<TCAMainC>

    var body: some View {
        VStack(spacing: 24) {
            TCAViewerView(
                store: store.scope(state: \.viewer, action: \.viewer)
            )

            TCAControllerView(
                store: store.scope(state: \.controller, action: \.controller)
            )
        }
    }
}
```
각 View 파일은 자신의 Store를 받아 UI만 담당하므로, 형제 간 통신 흐름을 시각적으로 쉽게 확인할 수 있습니다.
