# 6-alert — AlertState 처리

카운터를 초기화하기 위한 확인 Alert를 상태 기반으로 띄우고 닫습니다.

## TCA 기능, 설명, 예시 코드

### 1. `@Presents` AlertState 선언
- 설명: 알럿 표시 여부와 버튼 구성을 `@Presents var alert`에 저장합니다.
```swift
@Reducer
struct TCADelCounter {
    @ObservableState
    struct State: Equatable {
        var count = 0
        @Presents var alert: AlertState<Action.Alert>?
    }
    ...
}
```

### 2. AlertState DSL과 `PresentationAction`
- 설명: `.deleteButtonTapped`에서 AlertState를 생성하고, 버튼 액션은 `.alert(.presented(...))`로 다시 리듀서에 도착합니다.
```swift
enum Action: Equatable {
    case incrementButtonTapped
    case deleteButtonTapped
    case alert(PresentationAction<Alert>)

    enum Alert: Equatable {
        case confirmDelete
        case cancel
    }
}

var body: some Reducer<State, Action> {
    Reduce { state, action in
        switch action {
        case .deleteButtonTapped:
            state.alert = AlertState {
                TextState("Reset Counter?")
            } actions: {
                ButtonState(role: .destructive, action: .confirmDelete) {
                    TextState("Reset")
                }
                ButtonState(role: .cancel, action: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("This will set the counter to zero.")
            }
            return .none

        case .alert(.presented(.confirmDelete)):
            state.count = 0
            state.alert = nil
            return .none
        ...
        }
    }
}
```

### 3. SwiftUI `.alert`와 Store 스코프
- 설명: SwiftUI는 `alert` 수식어에 Store 스코프를 넘기고, 상태가 nil이면 알럿이 닫힙니다.
```swift
struct TCADelCounterView: View {
    @State var store: StoreOf<TCADelCounter>

    var body: some View {
        VStack {
            Text("Count: \(store.count)")
            Button("Reset") {
                store.send(.deleteButtonTapped)
            }
        }
        .alert(
            $store.scope(state: \.alert, action: \.alert)
        )
    }
}
```
