# 5-scope — 부모/자식 피처 구성

Todo와 Counter 두 자식을 `Scope`로 묶어 부모가 상태를 공유하고 delegate 액션으로 콜백을 받습니다.

## TCA 기능, 설명, 예시 코드

### 1. `Scope`로 자식 리듀서 연결
- 설명: 부모 리듀서가 `Scope`를 통해 자식 상태/액션을 각각의 피처에 위임합니다.
```swift
@Reducer
struct TCATodoBoard {
    @ObservableState
    struct State: Equatable {
        var todo = TCATodo.State()
        var counter = TCATodoCounter.State()
        var statusMessage: String?
        var boardLog: [String] = []
    }

    enum Action: Equatable {
        case todo(TCATodo.Action)
        case counter(TCATodoCounter.Action)
        case dismissStatusMessage
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.todo, action: \.todo) { TCATodo() }
        Scope(state: \.counter, action: \.counter) { TCATodoCounter() }
        Reduce { state, action in ... }
    }
}
```

### 2. Delegate 액션으로 자식 → 부모 콜백
- 설명: 카운터가 목표를 달성하면 `.send(.delegate(.reachedTen))`을 반환하고 부모가 축하 메시지를 띄웁니다.
```swift
@Reducer
struct TCATodoCounter {
    enum Action: Equatable {
        case increment
        case decrement
        case delegate(Delegate)
        enum Delegate: Equatable { case reachedTen }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increment:
                state.count += 1
                if state.count == state.target {
                    return .send(.delegate(.reachedTen))
                }
                return .none
            ...
            case .delegate:
                return .none
            }
        }
    }
}

// 부모 리듀서
case .counter(.delegate(.reachedTen)):
    let message = "카운터가 \(state.counter.target)회에 도달했습니다!"
    state.statusMessage = message
    state.boardLog.append("🎯 \(message)")
    state.counter.count = 0
    return .none
```

### 3. `store.scope`로 뷰 구성요소 분리
- 설명: 하나의 부모 Store에서 자식 Store를 스코프해 각각의 SwiftUI 뷰를 독립적으로 렌더링합니다.
```swift
struct TCATodoBoardView: View {
    @Bindable var store: StoreOf<TCATodoBoard>

    var body: some View {
        ScrollView {
            TCATodoView(
                store: store.scope(state: \.todo, action: \.todo)
            )
            TCATodoCounterView(
                store: store.scope(state: \.counter, action: \.counter)
            )
        }
    }
}
```
